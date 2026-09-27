import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/services/purchase_service.dart';
import 'package:avan_app/screens/paywall/paywall_screen.dart';
import 'package:avan_app/widgets/paywall_modal.dart';

import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

class FakeInAppPurchase implements InAppPurchase {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<String> countryCode() async => 'US';

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async => true;

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam, bool autoConsume = true}) async => true;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async {
    return ProductDetailsResponse(
      productDetails: [],
      notFoundIDs: identifiers.toList(),
    );
  }

  @override
  T getPlatformAddition<T extends InAppPurchasePlatformAddition?>() {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PurchaseService.customIapInstance = FakeInAppPurchase();
    SharedPreferences.setMockInitialValues({
      'premiumStatus': false,
      'onboarding_completed': false,
    });
  });

  tearDown(() {
    PurchaseService.customIapInstance = null;
  });

  group('PurchaseService Unit Tests', () {
    test('Fallback products and pricing calculations resolve properly', () {
      final service = PurchaseService();
      expect(service.weeklyProduct.id, PurchaseService.weeklySubscriptionId);
      expect(service.weeklyProduct.rawPrice, 3.99);
      expect(service.monthlyProduct.id, PurchaseService.monthlySubscriptionId);
      expect(service.monthlyProduct.rawPrice, 14.99);
      expect(service.annualProduct.id, PurchaseService.annualSubscriptionId);
      expect(service.annualProduct.rawPrice, 49.99);
      expect(service.annualMonthlyEquivalent, '\$4.17/mo');
      expect(service.annualSavingsPercentage, '72%');
    });

    test('buyProduct and restorePurchases execute in sandbox environment', () async {
      final service = PurchaseService();
      bool premiumNotified = false;

      await service.initialize((isPremium) {
        premiumNotified = isPremium;
      });

      final bought = await service.buyProduct(PurchaseService.annualSubscriptionId);
      expect(bought, isTrue);
      expect(premiumNotified, isTrue);

      final restored = await service.restorePurchases();
      expect(restored, isTrue);
    });
  });

  group('PaywallScreen Widget Tests', () {
    testWidgets('PaywallScreen renders hero typography, feature cards, and trial timeline', (tester) async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: PaywallScreen(isOnboarding: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check hero elements
      expect(find.text('AVAN UNLIMITED ACCESS'), findsOneWidget);
      expect(find.text('Awaken Your Highest Potential'), findsOneWidget);

      // Check trial timeline
      expect(find.text('NO COMMITMENT • CANCEL ANYTIME'), findsOneWidget);
      expect(find.text('Today: Instant VIP Access'), findsOneWidget);
      expect(find.text('Day 5: Friendly Reminder'), findsOneWidget);
      expect(find.text('Day 7: First Billing Cycle'), findsOneWidget);

      // Check all 3 plan cards
      expect(find.text('Annual Membership'), findsOneWidget);
      expect(find.text('Monthly Membership'), findsOneWidget);
      expect(find.text('Weekly Membership'), findsOneWidget);

      // Check primary CTA button
      expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
    });

    testWidgets('Toggling plans switches CTA between Annual, Monthly, and Weekly', (tester) async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: PaywallScreen(isOnboarding: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll down to reveal Monthly Membership
      await tester.scrollUntilVisible(find.text('Monthly Membership'), 200);
      await tester.tap(find.text('Monthly Membership'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock AVAN Monthly'), findsOneWidget);

      // Tap Weekly Membership
      await tester.scrollUntilVisible(find.text('Weekly Membership'), 100);
      await tester.tap(find.text('Weekly Membership'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock AVAN Weekly'), findsOneWidget);

      // Scroll back up to Annual plan
      await tester.scrollUntilVisible(find.text('Annual Membership'), -100);
      await tester.tap(find.text('Annual Membership'));
      await tester.pumpAndSettle();

      expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
    });

    testWidgets('Tapping Start 7-Day Free Trial triggers purchase and sets isPremium', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appProvider = AppProvider();
      await appProvider.loadState();
      expect(appProvider.isPremium, isFalse);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: PaywallScreen(isOnboarding: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start 7-Day Free Trial'), warnIfMissed: true);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));

      expect(appProvider.isPremium, isTrue);
    });
  });

  group('PaywallModal Widget Tests', () {
    testWidgets('PaywallModal renders compact options and links to full paywall', (tester) async {
      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppProvider>.value(
          value: appProvider,
          child: const MaterialApp(
            home: Scaffold(
              body: PaywallModal(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unlock AVAN Unlimited ✨'), findsOneWidget);
      expect(find.text('Annual Membership (7-Day Trial)'), findsOneWidget);
      expect(find.text('Monthly Membership'), findsOneWidget);
      expect(find.text('Weekly Membership'), findsOneWidget);
      expect(find.text('See full feature breakdown & trial timeline →'), findsOneWidget);
    });
  });
}
