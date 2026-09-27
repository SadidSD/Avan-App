import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:adapty_flutter/adapty_flutter.dart';

/// Production Adapty Subscription & Paywall Service for AVAN.
/// Manages initialization, real-time entitlement validation, dynamic flow/product fetching,
/// user identification linking with Firebase Auth, and native purchases.
class AdaptyService {
  static final AdaptyService _instance = AdaptyService._internal();
  factory AdaptyService() => _instance;
  AdaptyService._internal();

  /// Public SDK Key from the Adapty Dashboard.
  static const String publicApiKey = 'public_live_2m5GI2w7.2lrvMP8eBt9VZmbTZXDN';

  /// Standard Access Level ID configured in Adapty Dashboard.
  static const String premiumAccessLevelId = 'premium';

  /// Standard Placement ID for paywalls.
  static const String mainPlacementId = 'avan_main_paywall';

  bool _isInitialized = false;
  bool _isPremium = false;
  AdaptyProfile? _currentProfile;
  Function(bool isPremium)? _onPremiumChanged;
  StreamSubscription<AdaptyProfile>? _profileSubscription;

  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  AdaptyProfile? get currentProfile => _currentProfile;

  /// Activates the Adapty SDK and subscribes to real-time subscription status changes.
  Future<void> initialize([Function(bool isPremium)? onPremiumChanged]) async {
    if (onPremiumChanged != null) {
      _onPremiumChanged = onPremiumChanged;
    }

    if (_isInitialized) {
      if (_onPremiumChanged != null) {
        _onPremiumChanged!(_isPremium);
      }
      return;
    }

    try {
      final config = AdaptyConfiguration(apiKey: publicApiKey)
        ..withObserverMode(false)
        ..withLogLevel(kDebugMode ? AdaptyLogLevel.verbose : AdaptyLogLevel.error);

      await Adapty().activate(configuration: config);

      // Listen to real-time profile / entitlement updates (e.g. renewal, cancellation, web purchase)
      _profileSubscription?.cancel();
      _profileSubscription = Adapty().didUpdateProfileStream.listen((profile) {
        _updateProfileState(profile);
      });

      // Fetch initial profile
      final profile = await Adapty().getProfile();
      _updateProfileState(profile);

      _isInitialized = true;
      debugPrint('[AdaptyService] Initialized successfully. Premium active: $_isPremium');
    } catch (e) {
      debugPrint('[AdaptyService] Initialization error (handled): $e');
      _isInitialized = false;
    }
  }

  void _updateProfileState(AdaptyProfile profile) {
    _currentProfile = profile;
    final active = profile.accessLevels[premiumAccessLevelId]?.isActive ?? false;
    _isPremium = active;
    debugPrint('[AdaptyService] Profile updated. Premium: $_isPremium');
    if (_onPremiumChanged != null) {
      _onPremiumChanged!(_isPremium);
    }
  }

  /// Fetches the dynamic flow/paywall configured in Adapty Dashboard.
  Future<AdaptyFlow?> getFlow({String placementId = mainPlacementId}) async {
    if (!_isInitialized) return null;
    try {
      final flow = await Adapty().getFlow(placementId: placementId);
      return flow;
    } catch (e) {
      debugPrint('[AdaptyService] getFlow error for $placementId: $e');
      return null;
    }
  }

  /// Fetches products attached to a flow from Google Play / App Store.
  Future<List<AdaptyPaywallProduct>> getPaywallProducts({AdaptyFlow? flow, String placementId = mainPlacementId}) async {
    if (!_isInitialized) return [];
    try {
      final targetFlow = flow ?? await getFlow(placementId: placementId);
      if (targetFlow == null) return [];
      final products = await Adapty().getPaywallProducts(flow: targetFlow);
      return products;
    } catch (e) {
      debugPrint('[AdaptyService] getPaywallProducts error: $e');
      return [];
    }
  }

  /// Purchases a selected subscription product through Adapty.
  Future<bool> makePurchase(AdaptyPaywallProduct product) async {
    if (!_isInitialized) return false;
    try {
      final result = await Adapty().makePurchase(product: product);
      switch (result) {
        case AdaptyPurchaseResultSuccess(:final profile):
          _updateProfileState(profile);
          return _isPremium;
        case AdaptyPurchaseResultPending():
          debugPrint('[AdaptyService] Purchase is pending completion.');
          return false;
        case AdaptyPurchaseResultUserCancelled():
          debugPrint('[AdaptyService] User cancelled purchase.');
          return false;
        case null:
          return false;
      }
    } catch (e) {
      debugPrint('[AdaptyService] makePurchase error: $e');
      return false;
    }
  }

  /// Restores previous purchases across devices or reinstalls.
  Future<bool> restorePurchases() async {
    if (!_isInitialized) return false;
    try {
      final profile = await Adapty().restorePurchases();
      _updateProfileState(profile);
      return _isPremium;
    } catch (e) {
      debugPrint('[AdaptyService] restorePurchases error: $e');
      return false;
    }
  }

  /// Links the user's Firebase Auth UID to their Adapty customer profile.
  Future<void> identifyUser(String customerUserId) async {
    if (!_isInitialized) return;
    try {
      await Adapty().identify(customerUserId);
      debugPrint('[AdaptyService] User identified: $customerUserId');
    } catch (e) {
      debugPrint('[AdaptyService] identifyUser error: $e');
    }
  }

  /// Clears customer identity upon sign-out, returning to an anonymous profile.
  Future<void> logoutUser() async {
    if (!_isInitialized) return;
    try {
      await Adapty().logout();
      debugPrint('[AdaptyService] User logged out from Adapty.');
    } catch (e) {
      debugPrint('[AdaptyService] logoutUser error: $e');
    }
  }
}
