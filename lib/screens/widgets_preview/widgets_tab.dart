import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';

class WidgetsTab extends StatefulWidget {
  const WidgetsTab({Key? key}) : super(key: key);

  @override
  State<WidgetsTab> createState() => _WidgetsTabState();
}

class _WidgetsTabState extends State<WidgetsTab> {
  String _selectedWidgetType = 'Lock Screen'; // Lock Screen, Small Home, Medium Home, Large Home
  String _selectedContentType = 'Daily Affirmation'; // Daily Affirmation, Streak Tracker, Quick Player
  String _selectedTheme = 'Dark Espresso'; // Dark Espresso, Soft Beige, Warm Gradient, Minimal White
  String _selectedRefreshFreq = 'Every 6 Hours'; // Every 2 Hours, Every 6 Hours, Daily
  String _selectedFont = 'Clean Sans'; // Clean Sans, Elegant Serif, Bold Rounded

  Color get _widgetBgColor {
    switch (_selectedTheme) {
      case 'Dark Espresso':
        return AppColors.buttonDark;
      case 'Soft Beige':
        return AppColors.softBeige;
      case 'Warm Gradient':
        return AppColors.nudeAccent;
      case 'Minimal White':
      default:
        return Colors.white;
    }
  }

  Color get _widgetTextColor {
    if (_selectedTheme == 'Dark Espresso') return Colors.white;
    return AppColors.textPrimary;
  }

  Color get _widgetSubtextColor {
    if (_selectedTheme == 'Dark Espresso') return AppColors.nudeAccent;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Widgets Studio 🎨',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro
              const Text(
                'Customize Lock & Home Widgets',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Keep daily affirmations and progress right on your phone screen.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Widget Type Segment
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Lock Screen', 'Small (1x1)', 'Medium (2x1)', 'Large (2x2)'].map((type) {
                    final isSelected = _selectedWidgetType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedWidgetType = type),
                        selectedColor: AppColors.buttonDark,
                        backgroundColor: AppColors.softBeige,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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
                    const Text(
                      'LIVE PREVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.tanAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDynamicWidgetPreview(),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Customization Controls
              const Text(
                'Widget Options',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Content Selector
              _buildOptionDropdown(
                label: 'Widget Content',
                value: _selectedContentType,
                options: ['Daily Affirmation', 'Streak Tracker', 'Quick Player'],
                onChanged: (val) => setState(() => _selectedContentType = val!),
              ),
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
                text: 'Add Widget to Screen ✨',
                onPressed: () => _showAddWidgetInstructions(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicWidgetPreview() {
    double width = 300;
    double height = 120;

    if (_selectedWidgetType == 'Small (1x1)') {
      width = 160;
      height = 160;
    } else if (_selectedWidgetType == 'Medium (2x1)') {
      width = 320;
      height = 150;
    } else if (_selectedWidgetType == 'Large (2x2)') {
      width = 320;
      height = 240;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _widgetBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSoft, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A5A4B44),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: _buildPreviewContent(),
    );
  }

  Widget _buildPreviewContent() {
    if (_selectedContentType == 'Streak Tracker') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: AppColors.goldAccent, size: 36),
          const SizedBox(height: 6),
          Text(
            '12 Day Streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _widgetTextColor,
            ),
          ),
          Text(
            'Consistency brings mastery',
            style: TextStyle(fontSize: 11, color: _widgetSubtextColor),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (_selectedContentType == 'Quick Player') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_rounded, color: AppColors.goldAccent, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Morning Energy Playlist',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _widgetTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.skip_previous_rounded, color: _widgetTextColor),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.goldAccent, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
              Icon(Icons.skip_next_rounded, color: _widgetTextColor),
            ],
          ),
        ],
      );
    }

    // Default: Daily Affirmation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 14, color: _widgetSubtextColor),
            const SizedBox(width: 6),
            Text(
              'DAILY AFFIRMATION • AVAN',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _widgetSubtextColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '"I attract peace, abundance, and clarity into my life every day."',
          style: TextStyle(
            fontSize: _selectedWidgetType == 'Large (2x2)' ? 16 : 13,
            fontWeight: FontWeight.w600,
            color: _widgetTextColor,
            height: 1.3,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildOptionDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.buttonDark),
            items: options.map((opt) {
              return DropdownMenuItem(
                value: opt,
                child: Text(opt, style: const TextStyle(fontSize: 13, color: AppColors.buttonDark, fontWeight: FontWeight.w600)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showAddWidgetInstructions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
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
              const Text(
                'How to Add AVAN Widget',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildStepItem('1', 'Go to your phone\'s Home Screen or Lock Screen.'),
              _buildStepItem('2', 'Touch and hold an empty space until apps jiggle.'),
              _buildStepItem('3', 'Tap the (+) plus button at the top corner.'),
              _buildStepItem('4', 'Search for "AVAN" and select your custom widget layout.'),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Got It!',
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
            decoration: const BoxDecoration(color: AppColors.softBeige, shape: BoxShape.circle),
            child: Center(
              child: Text(step, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.buttonDark)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(instruction, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}
