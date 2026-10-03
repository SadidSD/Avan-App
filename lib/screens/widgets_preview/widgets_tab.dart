import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../widgets/avan_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../providers/app_provider.dart';
import '../../services/widget_service.dart';

class WidgetsTab extends StatefulWidget {
  const WidgetsTab({super.key});

  @override
  State<WidgetsTab> createState() => _WidgetsTabState();
}

class _WidgetsTabState extends State<WidgetsTab> {
  String _selectedWidgetType = 'Medium (4x2)'; // Lock Screen, Small (2x2), Medium (4x2), Large (4x4)
  String _selectedContentType = 'Daily Affirmation'; // Daily Affirmation, Streak Tracker, Quick Player
  String _selectedTheme = 'Dark Espresso'; // Dark Espresso, Soft Beige, Warm Gradient, Minimal White
  String _selectedRefreshFreq = 'Every 6 Hours'; // Every 2 Hours, Every 6 Hours, Daily
  String _selectedFont = 'Elegant Serif'; // Clean Sans, Elegant Serif, Bold Rounded
  final TextEditingController _customAffirmationController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedWidgetSettings();
  }

  @override
  void dispose() {
    _customAffirmationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedWidgetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        String savedType = prefs.getString('pref_widget_type') ?? _selectedWidgetType;
        // Normalize legacy names to standard formations
        if (savedType == 'Small (1x1)') savedType = 'Small (2x2)';
        if (savedType == 'Medium (2x1)') savedType = 'Medium (4x2)';
        if (savedType == 'Large (2x2)') savedType = 'Large (4x4)';
        _selectedWidgetType = savedType;
        _selectedContentType = prefs.getString('pref_widget_content') ?? _selectedContentType;
        _selectedTheme = prefs.getString('pref_widget_theme') ?? _selectedTheme;
        _selectedRefreshFreq = prefs.getString('pref_widget_refresh') ?? _selectedRefreshFreq;
        _selectedFont = prefs.getString('pref_widget_font') ?? _selectedFont;
        _customAffirmationController.text = prefs.getString('pref_widget_custom_quote') ?? '';
      });
    } catch (_) {}
  }

  AvanWidgetSize get _currentAvanWidgetSize {
    switch (_selectedWidgetType) {
      case 'Small (2x2)':
      case 'Small (1x1)':
        return AvanWidgetSize.small;
      case 'Medium (4x2)':
      case 'Medium (2x1)':
        return AvanWidgetSize.medium;
      case 'Large (4x4)':
      case 'Large (2x2)':
        return AvanWidgetSize.large;
      case 'Lock Screen':
      default:
        return AvanWidgetSize.lockScreen;
    }
  }

  Future<void> _saveWidgetSettings(AppProvider appProvider) async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_widget_type', _selectedWidgetType);
      await prefs.setString('pref_widget_content', _selectedContentType);
      await prefs.setString('pref_widget_theme', _selectedTheme);
      await prefs.setString('pref_widget_refresh', _selectedRefreshFreq);
      await prefs.setString('pref_widget_font', _selectedFont);
      await prefs.setString('pref_widget_custom_quote', _customAffirmationController.text.trim());

      // Push updated content to native Home Screen & Lock Screen widget storage
      await WidgetService.instance.updateWidgets(
        affirmation: appProvider.getHeroAffirmation(),
        streakDays: appProvider.streakData.currentStreak,
        theme: _selectedTheme,
        font: _selectedFont,
        refreshFreq: _selectedRefreshFreq,
        customQuote: _selectedContentType == 'Custom Affirmation'
            ? _customAffirmationController.text.trim()
            : null,
        category: _selectedContentType == 'Custom Affirmation' ? 'My Mantra' : null,
        mood: appProvider.selectedMood.isNotEmpty ? appProvider.selectedMood : 'Peaceful',
      );
    } catch (e) {
      debugPrint('[WidgetsTab] save settings error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color get _widgetBgColor {
    switch (_selectedTheme) {
      case 'Dark Espresso':
        return AppColors.surfaceElevated;
      case 'Soft Beige':
        return const Color(0xFFF7F2EB);
      case 'Warm Gradient':
        return const Color(0xFF2C1E19);
      case 'Minimal White':
      default:
        return Colors.white;
    }
  }

  Color get _widgetTextColor {
    if (_selectedTheme == 'Dark Espresso' || _selectedTheme == 'Warm Gradient') {
      return AppColors.textPrimary;
    }
    return const Color(0xFF1E1E1E);
  }

  Color get _widgetSubtextColor {
    if (_selectedTheme == 'Dark Espresso' || _selectedTheme == 'Warm Gradient') {
      return AppColors.textSecondary;
    }
    return const Color(0xFF6E655F);
  }

  TextStyle _getPreviewFontStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    FontStyle? fontStyle,
  }) {
    switch (_selectedFont) {
      case 'Elegant Serif':
        return GoogleFonts.cormorantGaramond(
          fontSize: fontSize + 2,
          fontWeight: fontWeight,
          color: color,
          height: height ?? 1.25,
          fontStyle: fontStyle ?? FontStyle.italic,
        );
      case 'Bold Rounded':
        return GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: color,
          height: height ?? 1.3,
        );
      case 'Clean Sans':
      default:
        return GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height ?? 1.3,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AvanAppBar(
        title: 'Widgets Studio',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.widgets_rounded, color: accent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OS Home & Lock Widgets',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Live sync affirmations & streaks straight to your phone display.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Widget Type Segment
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Lock Screen', 'Small (2x2)', 'Medium (4x2)', 'Large (4x4)'].map((type) {
                    final isSelected = _selectedWidgetType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedWidgetType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? accent.withOpacity(0.18) : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? accent : AppColors.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            type,
                            style: GoogleFonts.inter(
                              color: isSelected ? accent : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Live Preview Canvas
              Center(
                child: Column(
                  children: [
                    Text(
                      'LIVE PREVIEW',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDynamicWidgetPreview(appProvider, accent),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Customization Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Widget Options',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_selectedContentType != 'Custom Affirmation')
                    GestureDetector(
                      onTap: () => setState(() => _selectedContentType = 'Custom Affirmation'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accent.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_note_rounded, size: 16, color: accent),
                            const SizedBox(width: 4),
                            Text(
                              'Write Custom',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Content Selector
              _buildOptionDropdown(
                label: 'Widget Content',
                value: _selectedContentType,
                options: ['Daily Affirmation', 'Custom Affirmation', 'Streak Tracker', 'Quick Player'],
                onChanged: (val) => setState(() => _selectedContentType = val!),
              ),
              if (_selectedContentType == 'Custom Affirmation') ...[
                const SizedBox(height: 12),
                _buildCustomAffirmationEditor(accent),
              ] else ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _selectedContentType = 'Custom Affirmation'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withOpacity(0.25), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Want to write your own words? ✍️',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Tap here to type a custom mantra for your widgets.',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: accent, size: 12),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Theme Selector
              _buildOptionDropdown(
                label: 'Background Theme',
                value: _selectedTheme,
                options: ['Dark Espresso', 'Soft Beige', 'Warm Gradient', 'Minimal White'],
                onChanged: (val) => setState(() => _selectedTheme = val!),
              ),
              const SizedBox(height: 12),

              // Refresh Frequency Selector
              _buildOptionDropdown(
                label: 'Refresh Frequency',
                value: _selectedRefreshFreq,
                options: ['Every 2 Hours', 'Every 6 Hours', 'Daily'],
                onChanged: (val) => setState(() => _selectedRefreshFreq = val!),
              ),
              const SizedBox(height: 12),

              // Font Style Selector
              _buildOptionDropdown(
                label: 'Typography Style',
                value: _selectedFont,
                options: ['Clean Sans', 'Elegant Serif', 'Bold Rounded'],
                onChanged: (val) => setState(() => _selectedFont = val!),
              ),
              const SizedBox(height: 28),

              // Add Widget Button
              CustomButton(
                text: _isSaving ? 'Syncing Widget...' : 'Save & Add Widget to Screen ✨',
                onPressed: _isSaving
                    ? () {}
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await _saveWidgetSettings(appProvider);
                        final pinned = await WidgetService.instance.requestPinWidget(_currentAvanWidgetSize);
                        if (!context.mounted) return;
                        if (pinned) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Widget successfully pinned to your home screen! 🎉✨'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.growthAccent,
                            ),
                          );
                        } else {
                          _showAddWidgetInstructions(context);
                        }
                      },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicWidgetPreview(AppProvider appProvider, Color accent) {
    if (_selectedWidgetType == 'Lock Screen') {
      return Container(
        width: 310,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [Color(0xFF191615), Color(0xFF2B211C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lock indicator + Date
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, size: 12, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 5),
                Text(
                  'WEDNESDAY, SEP 17',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Lock screen time
            Text(
              '09:41',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 14),
            // Standard Lock Screen Widget Capsule (AccessoryRectangular)
            Container(
              width: 276,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildLockScreenContent(appProvider, accent),
            ),
          ],
        ),
      );
    }

    double width = 324;
    double height = 155;

    if (_selectedWidgetType == 'Small (2x2)' || _selectedWidgetType == 'Small (1x1)') {
      width = 158;
      height = 158;
    } else if (_selectedWidgetType == 'Medium (4x2)' || _selectedWidgetType == 'Medium (2x1)') {
      width = 324;
      height = 155;
    } else if (_selectedWidgetType == 'Large (4x4)' || _selectedWidgetType == 'Large (2x2)') {
      width = 310;
      height = 310;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _widgetBgColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _buildPreviewContent(appProvider, accent),
    );
  }

  Widget _buildLockScreenContent(AppProvider appProvider, Color accent) {
    if (_selectedContentType == 'Streak Tracker') {
      final streak = appProvider.streakData.currentStreak;
      return Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$streak Day Streak',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Daily Mindful Continuity',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_selectedContentType == 'Quick Player') {
      return Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Daily Mindset Journey',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Tap to resume affirmations',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Default: Daily Affirmation or Custom Affirmation on Lock Screen
    final hero = appProvider.getHeroAffirmation();
    final bool isCustom = _selectedContentType == 'Custom Affirmation';
    final String quote = (isCustom && _customAffirmationController.text.trim().isNotEmpty)
        ? _customAffirmationController.text.trim()
        : hero.quote;
    final String category = isCustom ? 'MY MANTRA' : hero.category.toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 11, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              '$category • AVAN',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          '"$quote"',
          style: _getPreviewFontStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.25,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPreviewContent(AppProvider appProvider, Color accent) {
    final bool isSmall = _selectedWidgetType.startsWith('Small');
    final bool isLarge = _selectedWidgetType.startsWith('Large');

    if (_selectedContentType == 'Streak Tracker') {
      final streak = appProvider.streakData.currentStreak;
      if (isSmall) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.goldAccent, size: 34),
            const SizedBox(height: 4),
            Text(
              '$streak',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: _widgetTextColor,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Day Streak',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _widgetSubtextColor,
              ),
            ),
          ],
        );
      }

      if (isLarge) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.goldAccent, size: 20),
                const SizedBox(width: 6),
                Text(
                  'MINDFUL HABIT STREAK',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: _widgetSubtextColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withOpacity(0.16),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldAccent.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_fire_department_rounded, color: AppColors.goldAccent, size: 40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$streak Days Active',
                    style: _getPreviewFontStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _widgetTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Consistency rewires neural pathways',
                    style: GoogleFonts.inter(fontSize: 12, color: _widgetSubtextColor),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // 7-day habit continuity indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _widgetTextColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }

      // Medium (4x2)
      return Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: AppColors.goldAccent, size: 34),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$streak Day Streak',
                  style: _getPreviewFontStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _widgetTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily affirmations rewire your subconscious belief patterns.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: _widgetSubtextColor, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_selectedContentType == 'Quick Player') {
      if (isSmall) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Daily Player',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _widgetTextColor,
              ),
            ),
            Text(
              'Tap to Listen',
              style: GoogleFonts.inter(fontSize: 10, color: _widgetSubtextColor),
            ),
          ],
        );
      }

      if (isLarge) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.spa_rounded, color: accent, size: 18),
                const SizedBox(width: 6),
                Text(
                  'AFFIRMATION SOUNDSCAPE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: _widgetSubtextColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
                    ),
                    child: Center(
                      child: Icon(Icons.graphic_eq_rounded, color: accent, size: 40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Daily Mindset Activation',
                    style: _getPreviewFontStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _widgetTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '528Hz Solfeggio • Guided Audio',
                    style: GoogleFonts.inter(fontSize: 11.5, color: _widgetSubtextColor),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.skip_previous_rounded, color: _widgetTextColor, size: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                ),
                Icon(Icons.skip_next_rounded, color: _widgetTextColor, size: 24),
              ],
            ),
          ],
        );
      }

      // Medium (4x2)
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.spa_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daily Mindset Activation',
                  style: _getPreviewFontStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _widgetTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('528Hz', style: GoogleFonts.inter(fontSize: 10, color: accent, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.skip_previous_rounded, color: _widgetTextColor, size: 24),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
              ),
              Icon(Icons.skip_next_rounded, color: _widgetTextColor, size: 24),
            ],
          ),
        ],
      );
    }

    // Default: Daily Affirmation or Custom Affirmation
    final hero = appProvider.getHeroAffirmation();
    final bool isCustom = _selectedContentType == 'Custom Affirmation';
    final String quote = (isCustom && _customAffirmationController.text.trim().isNotEmpty)
        ? _customAffirmationController.text.trim()
        : hero.quote;
    final String category = isCustom ? 'MY MANTRA' : hero.category.toUpperCase();
    final String authorName = isCustom ? 'Personal Mantra' : (hero.author.isNotEmpty ? hero.author : 'AVAN');

    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 12, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _widgetSubtextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '"$quote"',
            style: _getPreviewFontStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _widgetTextColor,
              height: 1.25,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            'AVAN',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: _widgetSubtextColor,
            ),
          ),
        ],
      );
    }

    if (isLarge) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.auto_awesome_rounded, size: 14, color: accent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$category • AVAN',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: _widgetSubtextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${appProvider.streakData.currentStreak}d Streak',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldAccent,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '“',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 44,
              color: accent.withOpacity(0.5),
              height: 0.5,
            ),
          ),
          Text(
            quote,
            style: _getPreviewFontStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _widgetTextColor,
              height: 1.35,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '— $authorName',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: _widgetSubtextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedRefreshFreq,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _widgetSubtextColor,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Medium (4x2)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 13, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$category • AVAN',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: _widgetSubtextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _selectedRefreshFreq,
              style: GoogleFonts.inter(fontSize: 10, color: _widgetSubtextColor),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Center(
            child: Text(
              '"$quote"',
              style: _getPreviewFontStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: _widgetTextColor,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Text(
          '— $authorName',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _widgetSubtextColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCustomAffirmationEditor(Color accent) {
    final suggestions = [
      'I am worthy of peace, happiness, and clarity.',
      'Today I choose calm over worry and strength over doubt.',
      'I am capable of achieving anything I set my mind to.',
      'I trust the timing of my life and embrace growth.',
      'I attract positivity, abundance, and focus every day.',
      'I am proud of who I am becoming and my daily progress.',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Write Your Custom Affirmation ✍️',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Type your personal mantra below to display on your lock screen & home widget.',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customAffirmationController,
            maxLines: 3,
            minLines: 2,
            maxLength: 120,
            onChanged: (text) => setState(() {}),
            style: GoogleFonts.inter(fontSize: 13.5, color: Colors.white, height: 1.35),
            decoration: InputDecoration(
              hintText: 'e.g. I am calm, confident, and grounded in this moment.',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
              filled: true,
              fillColor: const Color(0xFF13111C),
              counterStyle: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quick Suggestions (Tap to apply):',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () {
                  _customAffirmationController.text = s;
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surfaceElevated,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
              items: options.map((opt) {
                return DropdownMenuItem(
                  value: opt,
                  child: Text(
                    opt,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWidgetInstructions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.widgets_rounded, color: AppColors.goldAccent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Widget Setup Guide',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSolid,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '✅ Your customized layout and theme preset are saved! To place the widget on your home screen:',
                  style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Setup Steps (Android & iOS):',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildStepItem('1', 'Go to your phone\'s Home Screen or Lock Screen.'),
              _buildStepItem('2', 'Touch & hold an empty space until the menu appears.'),
              _buildStepItem('3', 'Tap Widgets (Android) or the (+) icon at the top (iOS).'),
              _buildStepItem('4', 'Select AVAN and place your customized widget layout.'),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Done',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepItem(String step, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.goldAccent.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldAccent.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                step,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.goldAccent, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
