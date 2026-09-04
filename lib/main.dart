import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/audio_provider.dart';
import 'screens/onboarding/emotional_onboarding_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AvanApp());
}

class AvanApp extends StatelessWidget {
  const AvanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final appContent = MaterialApp(
            title: 'AVAN - Mindset & Affirmation App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: appProvider.isOnboardingCompleted
                ? MainNavigationScreen()
                : const EmotionalOnboardingScreen(),
          );

          return MobileFrameWrapper(child: appContent);
        },
      ),
    );
  }
}

/// A responsive wrapper that frames the app like a sleek mobile smartphone when viewed on desktop browsers.
class MobileFrameWrapper extends StatelessWidget {
  final Widget child;

  const MobileFrameWrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is greater than 520px (e.g., desktop/laptop screen), render a phone device frame
        if (constraints.maxWidth > 520) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFFF5EDE4), // Warm beige center
                    Color(0xFFEDE3D8), // Slightly deeper cream edges
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 430,
                        maxHeight: constraints.maxHeight * 0.88 > 850 ? 850 : constraints.maxHeight * 0.88,
                      ),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFD4C4B0), // Metallic warm light
                            Color(0xFFB8A896), // Metallic warm mid
                            Color(0xFFCBBCA9), // Metallic warm
                            Color(0xFFA89888), // Metallic warm dark
                          ],
                          stops: [0.0, 0.4, 0.7, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(46),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x28D4A373), // Subtle ambient gold glow
                            blurRadius: 100,
                            spreadRadius: 15,
                          ),
                          BoxShadow(
                            color: Color(0x99000000), // Deep shadow for depth
                            blurRadius: 60,
                            spreadRadius: 8,
                            offset: Offset(0, 30),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(41),
                        child: Container(
                          color: AppColors.background,
                          child: MediaQuery(
                            // Override MediaQuery to simulate iPhone/Android screen dimensions
                            data: MediaQuery.of(context).copyWith(
                              size: Size(430, constraints.maxHeight * 0.88),
                              padding: const EdgeInsets.only(top: 54, bottom: 34),
                            ),
                            child: Stack(
                              children: [
                                child,
                                // Realistic Dynamic Island
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    width: 126,
                                    height: 37,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          blurRadius: 1,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 0.5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Camera Lens
                                        Container(
                                          margin: const EdgeInsets.only(right: 14),
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF111111),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.05),
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 4,
                                              height: 4,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF1A1A40), // Subtle lens reflection
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // AVAN Branding Text
                    const Text(
                      'A V A N',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 8.0,
                        color: AppColors.goldAccent,
                        shadows: [
                          Shadow(
                            color: Color(0x66D4A373),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Standard mobile display on narrow screens
        return child;
      },
    );
  }
}
