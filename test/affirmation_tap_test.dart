import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avan_app/providers/app_provider.dart';
import 'package:avan_app/providers/audio_provider.dart';
import 'package:avan_app/screens/main_navigation_screen.dart';
import 'package:avan_app/screens/player/player_screen.dart';
import 'package:avan_app/widgets/affirmation_card.dart';

void main() {
  testWidgets('Tapping AffirmationCard opens PlayerScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboardingStatus': true});

    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appProvider = AppProvider();
    final audioProvider = AudioProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>.value(value: appProvider),
          ChangeNotifierProvider<AudioProvider>.value(value: audioProvider),
        ],
        child: MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Find any AffirmationCard
    final cardFinder = find.byType(AffirmationCard);
    expect(cardFinder, findsWidgets);

    // Tap the first AffirmationCard
    await tester.tap(cardFinder.first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify PlayerScreen is open
    expect(find.byType(PlayerScreen), findsOneWidget);

    audioProvider.dispose();
  });
}
