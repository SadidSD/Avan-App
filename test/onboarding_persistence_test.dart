import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/main.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/screens/main_navigation_screen.dart';
import 'package:avan_app/screens/onboarding/emotional_onboarding_screen.dart';
import 'package:avan_app/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Onboarding Persistence & App Restart Tests', () {
    test('Fresh launch defaults to onboarding incomplete', () async {
      SharedPreferences.setMockInitialValues({});
      final appProvider = AppProvider();
      await appProvider.loadState();

      expect(appProvider.isOnboardingCompleted, isFalse);
      expect(appProvider.isInitialized, isTrue);
    });

    test('Completing onboarding persists to StorageService and SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final appProvider = AppProvider();
      await appProvider.loadState();

      expect(appProvider.isOnboardingCompleted, isFalse);

      await appProvider.completeOnboarding();
      expect(appProvider.isOnboardingCompleted, isTrue);

      final storage = StorageService();
      await storage.init();
      expect(storage.getOnboardingStatus(), isTrue);
    });

    test('Simulated app restart loads completed onboarding from storage', () async {
      // 1. Initial run: complete onboarding
      SharedPreferences.setMockInitialValues({});
      final firstLaunchProvider = AppProvider();
      await firstLaunchProvider.loadState();
      await firstLaunchProvider.completeOnboarding();

      // 2. Simulate app close and reopen: instantiate fresh AppProvider
      final secondLaunchProvider = AppProvider();
      await secondLaunchProvider.loadState();

      expect(secondLaunchProvider.isOnboardingCompleted, isTrue);
      expect(secondLaunchProvider.isInitialized, isTrue);
    });

    testWidgets('App opens directly to MainNavigationScreen when onboarding is complete', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'onboardingStatus': true});
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(AvanApp(appProvider: appProvider));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MainNavigationScreen), findsOneWidget);
      expect(find.byType(EmotionalOnboardingScreen), findsNothing);
    });

    testWidgets('App opens to EmotionalOnboardingScreen on fresh install', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'onboardingStatus': false});
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final appProvider = AppProvider();
      await appProvider.loadState();

      await tester.pumpWidget(AvanApp(appProvider: appProvider));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(EmotionalOnboardingScreen), findsOneWidget);
      expect(find.byType(MainNavigationScreen), findsNothing);
    });

    test('resetAppData properly clears onboardingStatus', () async {
      SharedPreferences.setMockInitialValues({'onboardingStatus': true});
      final appProvider = AppProvider();
      await appProvider.loadState();
      expect(appProvider.isOnboardingCompleted, isTrue);

      await appProvider.resetAppData();
      expect(appProvider.isOnboardingCompleted, isFalse);

      final storage = StorageService();
      await storage.init();
      expect(storage.getOnboardingStatus(), isFalse);
    });
  });
}
