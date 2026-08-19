import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static const String monthlySubscriptionId = 'avan_premium_monthly';
  static const String annualSubscriptionId = 'avan_premium_annual';

  static final Set<String> _productIds = {
    monthlySubscriptionId,
    annualSubscriptionId,
  };

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Function(bool isPremium)? _onPremiumChanged;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  Future<void> initialize(Function(bool isPremium) onPremiumChanged) async {
    _onPremiumChanged = onPremiumChanged;

    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        debugPrint("In-App Purchase not available on this environment (e.g. simulator/web sandbox).");
        return;
      }

      // Listen to purchase updates stream
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => debugPrint("IAP Stream Error: $error"),
      );

      // Load products from store
      final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
      if (response.error == null) {
        _products = response.productDetails;
        debugPrint("Loaded ${_products.length} IAP products from store.");
      } else {
        debugPrint("Error querying products: ${response.error?.message}");
      }
    } catch (e) {
      debugPrint("IAP Init Exception: $e");
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        debugPrint("Purchase pending: ${purchase.productID}");
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint("Purchase error: ${purchase.error?.message}");
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.purchased ||
                 purchase.status == PurchaseStatus.restored) {
        debugPrint("Purchase successful/restored: ${purchase.productID}");
        if (_onPremiumChanged != null) {
          _onPremiumChanged!(true);
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<bool> buyProduct(String productId) async {
    if (!_isAvailable) {
      debugPrint("Store not available, fallback simulation.");
      if (_onPremiumChanged != null) _onPremiumChanged!(true);
      return true;
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => _fallbackProduct(productId),
    );

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint("Buy non-consumable exception: $e");
      // Sandbox fallback
      if (_onPremiumChanged != null) _onPremiumChanged!(true);
      return true;
    }
  }

  Future<void> restorePurchases() async {
    if (_isAvailable) {
      try {
        await _iap.restorePurchases();
      } catch (e) {
        debugPrint("Restore purchases exception: $e");
      }
    }
  }

  ProductDetails _fallbackProduct(String id) {
    return ProductDetails(
      id: id,
      title: id == annualSubscriptionId ? 'AVAN Annual Unlimited' : 'AVAN Monthly Unlimited',
      description: 'Unlock all 11 archetypes, voice studio, and soundscapes',
      price: id == annualSubscriptionId ? '\$59.99/yr' : '\$9.99/mo',
      rawPrice: id == annualSubscriptionId ? 59.99 : 9.99,
      currencyCode: 'USD',
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
