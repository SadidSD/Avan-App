import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/affirmation.dart';

enum AvanWidgetSize {
  small,  // 1x1
  medium, // 2x1
  large,  // 2x2
  lockScreen,
}

class WidgetPayload {
  final String quote;
  final String author;
  final String category;
  final int streakDays;
  final String mood;
  final String theme;
  final String font;
  final String refreshFreq;

  const WidgetPayload({
    required this.quote,
    required this.author,
    required this.category,
    required this.streakDays,
    required this.mood,
    required this.theme,
    required this.font,
    required this.refreshFreq,
  });

  Map<String, dynamic> toMap() => {
        'quote': quote,
        'author': author,
        'category': category,
        'streakDays': streakDays,
        'mood': mood,
        'theme': theme,
        'font': font,
        'refreshFreq': refreshFreq,
      };
}

class WidgetService {
  static const String appGroupId = 'group.com.avanapp.avan_app';
  static const String androidSmallWidget = 'AvanSmallWidgetProvider';
  static const String androidMediumWidget = 'AvanMediumWidgetProvider';
  static const String androidLargeWidget = 'AvanLargeWidgetProvider';
  static const String iOSWidgetFamily = 'AvanWidgets';

  static final WidgetService instance = WidgetService._internal();
  WidgetService._internal();

  bool _initialized = false;

  /// Initialize the home_widget service
  Future<void> init() async {
    if (_initialized) return;
    try {
      if (!kIsWeb) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      _initialized = true;
    } catch (e) {
      debugPrint('[WidgetService] init error (handled): $e');
    }
  }

  /// Push updated content, streak, and preferences to native widgets
  Future<void> updateWidgets({
    required Affirmation? affirmation,
    required int streakDays,
    String? category,
    String? mood,
    String? theme,
    String? font,
    String? refreshFreq,
  }) async {
    await init();

    final prefs = await SharedPreferences.getInstance();
    final savedTheme = theme ?? prefs.getString('pref_widget_theme') ?? 'Soft Beige';
    final savedFont = font ?? prefs.getString('pref_widget_font') ?? 'Elegant Serif';
    final savedFreq = refreshFreq ?? prefs.getString('pref_widget_refresh') ?? 'Every 6 Hours';
    final savedMood = mood ?? prefs.getString('selected_mood') ?? 'Peaceful';

    final quote = affirmation?.quote ?? 'I am securely rooted in this exact moment, completely safe and capable.';
    final author = affirmation?.author ?? 'AVAN';
    final cat = category ?? affirmation?.category ?? 'Daily Mindset';

    try {
      if (!kIsWeb) {
        // Save strings to native shared memory
        await HomeWidget.saveWidgetData<String>('quote', quote);
        await HomeWidget.saveWidgetData<String>('author', author);
        await HomeWidget.saveWidgetData<String>('category', cat);
        await HomeWidget.saveWidgetData<int>('streakDays', streakDays);
        await HomeWidget.saveWidgetData<String>('mood', savedMood);
        await HomeWidget.saveWidgetData<String>('theme', savedTheme);
        await HomeWidget.saveWidgetData<String>('font', savedFont);
        await HomeWidget.saveWidgetData<String>('refreshFreq', savedFreq);

        // Signal native OS to invalidate views and reload timelines
        await HomeWidget.updateWidget(
          name: androidSmallWidget,
          androidName: androidSmallWidget,
          iOSName: iOSWidgetFamily,
        );
        await HomeWidget.updateWidget(
          name: androidMediumWidget,
          androidName: androidMediumWidget,
          iOSName: iOSWidgetFamily,
        );
        await HomeWidget.updateWidget(
          name: androidLargeWidget,
          androidName: androidLargeWidget,
          iOSName: iOSWidgetFamily,
        );
      }
    } catch (e) {
      debugPrint('[WidgetService] updateWidgets error (handled): $e');
    }
  }

  /// Request the OS to pin the selected widget directly to the home screen (Android 8.0+)
  Future<bool> requestPinWidget(AvanWidgetSize size) async {
    await init();
    if (kIsWeb) return false;

    String providerName;
    switch (size) {
      case AvanWidgetSize.small:
        providerName = androidSmallWidget;
        break;
      case AvanWidgetSize.medium:
        providerName = androidMediumWidget;
        break;
      case AvanWidgetSize.large:
        providerName = androidLargeWidget;
        break;
      case AvanWidgetSize.lockScreen:
        providerName = androidMediumWidget;
        break;
    }

    try {
      final supported = await HomeWidget.isRequestPinWidgetSupported();
      if (supported == true) {
        await HomeWidget.requestPinWidget(
          androidName: providerName,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[WidgetService] requestPinWidget error: $e');
      return false;
    }
  }

  /// Resolve styling colors from selected theme name
  Color getBackgroundColor(String theme) {
    switch (theme) {
      case 'Dark Espresso':
        return const Color(0xFF251A14);
      case 'Soft Beige':
        return const Color(0xFFFFF8F2);
      case 'Warm Gradient':
        return const Color(0xFFFBF0E6);
      case 'Minimal White':
      default:
        return const Color(0xFFFFFFFF);
    }
  }

  Color getPrimaryTextColor(String theme) {
    if (theme == 'Dark Espresso') return const Color(0xFFF5E6D3);
    return const Color(0xFF3D2C1E);
  }

  Color getSecondaryTextColor(String theme) {
    if (theme == 'Dark Espresso') return const Color(0xFFB8A089);
    return const Color(0xFF8B7355);
  }

  String getFontFamily(String font) {
    switch (font) {
      case 'Elegant Serif':
        return 'Cormorant Garamond';
      case 'Bold Rounded':
        return 'Plus Jakarta Sans';
      case 'Clean Sans':
      default:
        return 'Inter';
    }
  }
}
