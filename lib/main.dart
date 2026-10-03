import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/audio_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

import 'services/adapty_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent blank grey/white screens in release mode by displaying a rich interactive diagnostic view
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exception}');
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0D0D14),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                ),
                child: const Icon(Icons.bug_report_rounded, color: Colors.redAccent, size: 32),
              ),
              const SizedBox(height: 18),
              const Text(
                'View Render Issue Detected',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'A component failed to render. The error details below can be copied directly to resolve it:',
                style: TextStyle(color: Colors.white70, fontSize: 12.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    '${details.exception}\n\nStack:\n${details.stack}',
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Builder(
                    builder: (btnContext) => ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: 'AVAN Crash Report:\n${details.exception}\n\nStack:\n${details.stack}',
                        ));
                        ScaffoldMessenger.of(btnContext).showSnackBar(
                          const SnackBar(
                            content: Text('Error copied to clipboard! Paste it to developer.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Error Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldAccent,
                        foregroundColor: const Color(0xFF16130E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  };

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[Firebase] Init exception (handled): $e');
  }
  try {
    await AdaptyService().initialize();
  } catch (e) {
    debugPrint('[Adapty] Init exception (handled): $e');
  }
  final appProvider = AppProvider();
  await appProvider.loadState();
  runApp(AvanApp(appProvider: appProvider));
}

class AvanApp extends StatelessWidget {
  final AppProvider? appProvider;
  final bool showSplash;

  const AvanApp({Key? key, this.appProvider, this.showSplash = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (appProvider != null)
          ChangeNotifierProvider<AppProvider>.value(value: appProvider!)
        else
          ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
        ChangeNotifierProxyProvider<AppProvider, AudioProvider>(
          create: (_) => AudioProvider(),
          update: (_, appProvider, audioProvider) {
            final provider = audioProvider ?? AudioProvider();
            provider.onAffirmationCompleted = (aff) {
              appProvider.recordAudioAffirmationCompleted(aff);
            };
            provider.onAffirmationSkipped = (aff) {
              appProvider.recordAudioAffirmationSkipped(aff);
            };
            provider.onSessionCompleted = (pl) {
              appProvider.recordAudioSessionCompleted(pl);
            };
            return provider;
          },
        ),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'AVAN - Mindset & Affirmation App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            builder: (context, child) {
              return MobileFrameWrapper(child: child ?? const SizedBox());
            },
            home: AppStartupGate(showSplash: showSplash),
          );
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
          final mq = MediaQuery.maybeOf(context) ?? const MediaQueryData();
          return Container(
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
                            data: mq.copyWith(
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
            );
          }

        // Standard mobile display on narrow screens
        return child;
      },
    );
  }
}
