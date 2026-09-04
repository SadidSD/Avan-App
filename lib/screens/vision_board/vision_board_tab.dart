import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/affirmation_library.dart';
import '../../models/vision_board.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';

class VisionBoardTab extends StatefulWidget {
  const VisionBoardTab({Key? key}) : super(key: key);

  @override
  State<VisionBoardTab> createState() => _VisionBoardTabState();
}

class _VisionBoardTabState extends State<VisionBoardTab> {
  bool _showSavedBoards = false;
  final GlobalKey _gridKey = GlobalKey();

  final List<String> _templates = [
    '2 Blocks',
    '4 Blocks',
    '6 Blocks',
    '8 Blocks',
    'Minimal Layout',
    'Single Hero',
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isGrowth = appProvider.isGrowthMode;
    final accent = AppColors.accentForMode(isGrowth);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Vision Board',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_showSavedBoards)
            IconButton(
              icon: const Icon(Icons.wallpaper_rounded, color: AppColors.textPrimary),
              tooltip: 'Export as Lock Screen Wallpaper',
              onPressed: () => _exportAsWallpaper(context),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      const ButtonSegment(
                        value: false,
                        icon: Icon(Icons.dashboard_rounded, size: 16),
                        label: Text('Active Canvas'),
                      ),
                      ButtonSegment(
                        value: true,
                        icon: const Icon(Icons.collections_bookmark_rounded, size: 16),
                        label: Text('Saved (${appProvider.savedVisionBoards.length})'),
                      ),
                    ],
                    selected: {_showSavedBoards},
                    onSelectionChanged: (val) => setState(() => _showSavedBoards = val.first),
                    style: SegmentedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      selectedBackgroundColor: accent,
                      selectedForegroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _showSavedBoards
            ? const _SavedBoardsView()
            : _ActiveBoardView(
                gridKey: _gridKey,
                templates: _templates,
                onExportWallpaper: () => _exportAsWallpaper(context),
              ),
      ),
    );
  }

  Future<void> _exportAsWallpaper(BuildContext context) async {
    try {
      Uint8List? pngBytes;
      final boundary = _gridKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        pngBytes = byteData?.buffer.asUint8List();
      }

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.wallpaper_rounded, color: AppColors.goldAccent),
              SizedBox(width: 8),
              Text(
                'Lock Screen Wallpaper ✨',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (pngBytes != null)
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.goldAccent.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.memory(pngBytes, fit: BoxFit.cover),
                )
              else
                const Text(
                  'Your personalized vision board layout is optimized for high-resolution lock screen viewing.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
              const SizedBox(height: 14),
              Text(
                pngBytes != null
                    ? 'Rendered in 3x Retina HD. Save or screenshot this layout to anchor your subconscious goals every time you unlock your phone!'
                    : 'Tip: Capture or save this layout to keep your subconscious focused on your goals every time you unlock your phone!',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wallpaper generated & ready for lock screen! 📱✨'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save & Done', style: TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Export wallpaper error: $e");
    }
  }
}

// =============================================================================
// ACTIVE BOARD CANVAS VIEW
// =============================================================================
class _ActiveBoardView extends StatelessWidget {
  final GlobalKey gridKey;
  final List<String> templates;
  final VoidCallback onExportWallpaper;

  const _ActiveBoardView({
    Key? key,
    required this.gridKey,
    required this.templates,
    required this.onExportWallpaper,
  }) : super(key: key);

  int _getCrossAxisCount(String template) {
    if (template == 'Single Hero') return 1;
    return 2;
  }

  double _getAspectRatio(String template) {
    if (template == 'Single Hero') return 1.5;
    if (template == 'Minimal Layout') return 0.95;
    return 0.82;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final activeBoard = appProvider.activeVisionBoard;
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);

    return Column(
      children: [
        // Template Selector Chips
        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final t = templates[i];
              final isSelected = t == activeBoard.template;
              return ChoiceChip(
                label: Text(
                  t,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (val) {
                  if (val) appProvider.setActiveTemplate(t);
                },
                selectedColor: accent,
                backgroundColor: AppColors.surfaceElevated,
                side: BorderSide(color: isSelected ? Colors.transparent : AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            },
          ),
        ),

        // Grid Area
        Expanded(
          child: RepaintBoundary(
            key: gridKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: activeBoard.blocks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dashboard_customize_outlined, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'Your Vision Canvas is Empty',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add your first dream goal card or upload custom photos below!',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _getCrossAxisCount(activeBoard.template),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: _getAspectRatio(activeBoard.template),
                      ),
                      itemCount: activeBoard.blocks.length,
                      itemBuilder: (ctx, i) {
                        final block = activeBoard.blocks[i];
                        return _GoalCard(block: block);
                      },
                    ),
            ),
          ),
        ),

        // Bottom Editor Actions Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionBtn(
                icon: Icons.add_photo_alternate_rounded,
                label: 'Add Goal',
                color: accent,
                onTap: () => _addNewBlock(context),
              ),
              _buildActionBtn(
                icon: Icons.bookmark_add_rounded,
                label: 'Save Board',
                color: AppColors.textPrimary,
                onTap: () => _showSaveBoardDialog(context),
              ),
              _buildActionBtn(
                icon: Icons.wallpaper_rounded,
                label: 'Wallpaper',
                color: AppColors.textPrimary,
                onTap: onExportWallpaper,
              ),
              _buildActionBtn(
                icon: Icons.delete_sweep_rounded,
                label: 'Clear Canvas',
                color: AppColors.textSecondary,
                onTap: () => _confirmClearAll(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addNewBlock(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final newBlock = GoalBlock(
      id: 'gb_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Manifestation Goal',
      category: 'Mindset',
      bgImageUrl: 'assets/images/onboarding_moon_clouds.jpg',
      tintValue: 0xFF8A85A0,
      quote: 'I have the courage and focus to bring this vision into reality.',
      targetDate: '2026',
    );
    appProvider.addGoalBlock(newBlock);
  }

  void _showSaveBoardDialog(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final controller = TextEditingController(
      text: 'Vision Board ${DateFormat('MMM yyyy').format(DateTime.now())}',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Save Board Snapshot 📁', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Give your vision board collection a distinct title:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g., 2026 Career & Freedom',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              appProvider.saveActiveBoardAsNew(controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Board saved to Saved Boards collection! ✨'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save Board', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear Active Canvas?'),
        content: const Text('This will remove all blocks from your current active canvas. Saved boards will remain safe.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().clearActiveBoard();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// GOAL CARD WIDGET
// =============================================================================
class _GoalCard extends StatelessWidget {
  final GoalBlock block;
  const _GoalCard({Key? key, required this.block}) : super(key: key);

  ImageProvider _resolveImageProvider(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
      return NetworkImage(path);
    } else {
      if (!kIsWeb && path.isNotEmpty) {
        final file = File(path);
        if (file.existsSync()) return FileImage(file);
      }
      return const AssetImage('assets/images/onboarding_archway_sun.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openEditModal(context),
      onLongPress: () => _showQuickDeleteMenu(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          image: DecorationImage(
            image: _resolveImageProvider(block.bgImageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              block.tint.withOpacity(0.35),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Colors.black54, Colors.transparent, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Row: Category Badge + Target Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      block.category,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  if (block.targetDate.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.goldAccent.withOpacity(0.6), width: 0.8),
                      ),
                      child: Text(
                        block.targetDate,
                        style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
                      ),
                    ),
                ],
              ),

              // Title & Affirmative Quote
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.title,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"${block.quote}"',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.25,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditGoalModal(block: block),
    );
  }

  void _showQuickDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.textPrimary),
              title: const Text('Edit Goal Block'),
              onTap: () {
                Navigator.pop(ctx);
                _openEditModal(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Delete This Block', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                context.read<AppProvider>().deleteGoalBlock(block.id);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EDIT GOAL MODAL WITH PHOTO PICKER & AFFIRMATION LIBRARY PICKER
// =============================================================================
class _EditGoalModal extends StatefulWidget {
  final GoalBlock block;
  const _EditGoalModal({Key? key, required this.block}) : super(key: key);

  @override
  State<_EditGoalModal> createState() => _EditGoalModalState();
}

class _EditGoalModalState extends State<_EditGoalModal> {
  late TextEditingController _titleCtrl;
  late TextEditingController _quoteCtrl;
  late TextEditingController _targetDateCtrl;
  late String _category;
  late String _bgImageUrl;
  late int _tintValue;

  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Mindset',
    'Wealth',
    'Health',
    'Relationships',
    'Career',
    'Spiritual',
    'Travel',
  ];

  final Map<String, String> _curatedPresets = {
    'Archway Sun': 'assets/images/onboarding_archway_sun.jpg',
    'Girl Profile': 'assets/images/onboarding_girl_profile.jpg',
    'Moon & Clouds': 'assets/images/onboarding_moon_clouds.jpg',
    'Deep Meditation': 'assets/images/featured_meditation.jpg',
    'Night Sky': 'assets/images/sleep_story_night.jpg',
  };

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.block.title);
    _quoteCtrl = TextEditingController(text: widget.block.quote);
    _targetDateCtrl = TextEditingController(text: widget.block.targetDate);
    _category = widget.block.category;
    _bgImageUrl = widget.block.bgImageUrl;
    _tintValue = widget.block.tintValue;
  }

  Future<void> _pickCustomImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 88,
      );
      if (file != null) {
        setState(() {
          _bgImageUrl = file.path;
        });
      }
    } catch (e) {
      debugPrint("Photo picker error: $e");
    }
  }

  void _openAffirmationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          final quotes = comprehensiveAffirmationLibrary
              .where((a) => a.category.toLowerCase().contains(_category.toLowerCase()) || a.category.isNotEmpty)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Affirmation for $_category ✨',
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: quotes.length,
                    itemBuilder: (ctx, idx) {
                      final aff = quotes[idx];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CustomCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () {
                            setState(() {
                              _quoteCtrl.text = aff.quote;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('"${aff.quote}"', style: GoogleFonts.cormorantGaramond(fontSize: 16, fontStyle: FontStyle.italic, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(aff.category, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Goal Block 🎯',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                  tooltip: 'Delete Block',
                  onPressed: () {
                    appProvider.deleteGoalBlock(widget.block.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Goal Title
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),

            // Affirmative Quote + Library Quick-Pick Button
            TextField(
              controller: _quoteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Affirmative Quote',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _openAffirmationPicker,
                icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.goldAccent),
                label: const Text('Pick from Affirmation Library', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldAccent)),
              ),
            ),

            // Target Date Tag
            TextField(
              controller: _targetDateCtrl,
              decoration: InputDecoration(
                labelText: 'Target Date / Milestone (e.g. Dec 2026, Daily)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Category Chips
            Text('Category', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _categories.map((c) {
                final isSel = c == _category;
                return ChoiceChip(
                  label: Text(c, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.textPrimary)),
                  selected: isSel,
                  selectedColor: accent,
                  backgroundColor: AppColors.surfaceElevated,
                  onSelected: (val) {
                    if (val) setState(() => _category = c);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Background Image Section (Gallery / Camera Upload + Presets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Background Photo', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library_rounded, color: AppColors.goldAccent, size: 20),
                      tooltip: 'Pick from Phone Gallery',
                      onPressed: () => _pickCustomImage(ImageSource.gallery),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, color: AppColors.goldAccent, size: 20),
                      tooltip: 'Take a Photo',
                      onPressed: () => _pickCustomImage(ImageSource.camera),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Curated Presets Scroll
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Upload custom photo card
                  GestureDetector(
                    onTap: () => _pickCustomImage(ImageSource.gallery),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo_rounded, size: 20, color: AppColors.goldAccent),
                          SizedBox(height: 4),
                          Text('Upload', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),

                  // Presets
                  ..._curatedPresets.entries.map((e) {
                    final isSel = e.value == _bgImageUrl;
                    return GestureDetector(
                      onTap: () => setState(() => _bgImageUrl = e.value),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSel ? AppColors.goldAccent : Colors.transparent, width: 2.5),
                          image: DecorationImage(image: AssetImage(e.value), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Card Color Tint Swatches
            Text('Card Color Atmosphere', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                _buildColorSwatch(0xFF8A85A0), // Lavender Grey
                _buildColorSwatch(0xFF2A2A3E), // Midnight Navy
                _buildColorSwatch(0xFFFFD700), // Pure Gold
                _buildColorSwatch(0xFF00E5CC), // Electric Teal
                _buildColorSwatch(0xFFFF7BAC), // Rose Quartz
                _buildColorSwatch(0xFF0F1B4C), // Deep Sapphire
              ],
            ),
            const SizedBox(height: 26),

            // Save & Cancel Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final updated = widget.block.copyWith(
                        title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Goal',
                        quote: _quoteCtrl.text.trim(),
                        category: _category,
                        bgImageUrl: _bgImageUrl,
                        tintValue: _tintValue,
                        targetDate: _targetDateCtrl.text.trim(),
                      );
                      appProvider.updateGoalBlock(widget.block.id, updated);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch(int val) {
    final isSelected = _tintValue == val;
    return GestureDetector(
      onTap: () => setState(() => _tintValue = val),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Color(val),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
        ),
      ),
    );
  }
}

// =============================================================================
// SAVED BOARDS GALLERY VIEW
// =============================================================================
class _SavedBoardsView extends StatelessWidget {
  const _SavedBoardsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final boards = appProvider.savedVisionBoards;

    if (boards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.collections_bookmark_outlined, size: 54, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('No Saved Boards Yet', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('Tap "Save Board" in the active canvas to preserve named snapshots.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: boards.length,
      itemBuilder: (ctx, i) {
        final b = boards[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.dashboard_rounded, color: AppColors.goldAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text('${b.blocks.length} Goals • ${b.template} • ${DateFormat('MMM d, yyyy').format(b.lastModified)}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.goldAccent, size: 22),
                  tooltip: 'Load into Canvas',
                  onPressed: () {
                    appProvider.loadSavedBoard(b.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Loaded "${b.title}" into active canvas! ✨'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                  tooltip: 'Delete Board',
                  onPressed: () => appProvider.deleteSavedBoard(b.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
