import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/affirmation_library.dart';
import '../../models/vision_board.dart';
import '../../providers/app_provider.dart';
import '../../services/ambient_audio_synthesizer.dart';
import '../../services/audio_engine_service.dart';
import '../../services/wallpaper_export_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';

// =============================================================================
// CURATED AESTHETIC PACKS (66+ HIGH-RES ASSETS CATEGORIZED)
// =============================================================================
final Map<String, List<Map<String, String>>> curatedAestheticPacks = {
  'Abundance & Wealth': [
    {'title': 'Spring Gold', 'path': 'assets/images/abundance_spring_gold.jpg'},
    {'title': 'Skyline Poise', 'path': 'assets/images/negotiation_skyline_poise.jpg'},
    {'title': 'Abundance Hands', 'path': 'assets/images/scarcity_seedling_hands.jpg'},
    {'title': 'Chess Strategy', 'path': 'assets/images/ruthless_chess_king.jpg'},
    {'title': 'Golden Profile', 'path': 'assets/images/onboarding_girl_profile.jpg'},
  ],
  'Career & Ambition': [
    {'title': 'Deep Work Flow', 'path': 'assets/images/deep_work_flow.jpg'},
    {'title': 'Founder Resilience', 'path': 'assets/images/founder_resilience.jpg'},
    {'title': 'Executive Presence', 'path': 'assets/images/exec_presence_clarity.jpg'},
    {'title': 'Stage Spotlight', 'path': 'assets/images/public_stage_spotlight.jpg'},
    {'title': 'Crossroads', 'path': 'assets/images/career_pivot_crossroads.jpg'},
    {'title': 'Focus Desk', 'path': 'assets/images/antiprocrastination_desk.jpg'},
  ],
  'Peace & Mindset': [
    {'title': 'Archway Sun', 'path': 'assets/images/onboarding_archway_sun.jpg'},
    {'title': 'Solitude Hearth', 'path': 'assets/images/solitude_cabin_hearth.jpg'},
    {'title': 'Mountain Lake', 'path': 'assets/images/dopamine_mountain_lake.jpg'},
    {'title': 'Night Sky', 'path': 'assets/images/sleep_story_night.jpg'},
    {'title': 'Treehouse Calm', 'path': 'assets/images/inner_child_treehouse.jpg'},
    {'title': 'Candlelight Peace', 'path': 'assets/images/evening_pen_candle.jpg'},
  ],
  'Health & Vitality': [
    {'title': 'Morning Activation', 'path': 'assets/images/morning_neural_activation.jpg'},
    {'title': 'Deep Meditation', 'path': 'assets/images/featured_meditation.jpg'},
    {'title': 'Ridge Dawn', 'path': 'assets/images/endurance_ridge_dawn.jpg'},
    {'title': 'Body Neutrality', 'path': 'assets/images/body_neutrality_pool.jpg'},
    {'title': 'Recovery Fern', 'path': 'assets/images/injury_recovery_fern.jpg'},
    {'title': 'Spring Renewal', 'path': 'assets/images/chronic_pain_spring.jpg'},
  ],
  'Joy & Passion': [
    {'title': 'Studio Canvas', 'path': 'assets/images/creative_studio_canvas.jpg'},
    {'title': 'Sunrise Porch', 'path': 'assets/images/proud_sunrise_porch.jpg'},
    {'title': 'Gratitude Glow', 'path': 'assets/images/gratitude_neuro.jpg'},
    {'title': 'Moon & Clouds', 'path': 'assets/images/onboarding_moon_clouds.jpg'},
    {'title': 'Dopamine Bonsai', 'path': 'assets/images/dopamine_bonsai_calm.jpg'},
  ],
  'Strength & Armor': [
    {'title': 'Self Worth', 'path': 'assets/images/self_worth_found.jpg'},
    {'title': 'Boundary Gate', 'path': 'assets/images/boundary_orchard_gate.jpg'},
    {'title': 'Kintsugi Worth', 'path': 'assets/images/worth_rebuild_kint.jpg'},
    {'title': 'Lighthouse Shield', 'path': 'assets/images/lighthouse_storm_shield.jpg'},
    {'title': 'Stoic Bust', 'path': 'assets/images/stoic_marble_bust.jpg'},
  ],
  'Relationships & Love': [
    {'title': 'Social Trust Mugs', 'path': 'assets/images/social_trust_mugs.jpg'},
    {'title': 'Courtyard Roses', 'path': 'assets/images/avoidant_courtyard_roses.jpg'},
    {'title': 'Anchor Calm', 'path': 'assets/images/anxious_attachment_anchor.jpg'},
    {'title': 'Sunlit Room', 'path': 'assets/images/divorce_sunlit_room.jpg'},
  ],
};

ImageProvider resolveGoalImageProvider(String path) {
  if (path.startsWith('assets/')) {
    return AssetImage(path);
  } else if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('blob:')) {
    return NetworkImage(path);
  } else if (path.startsWith('data:image')) {
    try {
      final commaIndex = path.indexOf(',');
      if (commaIndex != -1) {
        final base64String = path.substring(commaIndex + 1);
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      }
    } catch (e) {
      debugPrint("Error decoding base64 image: $e");
    }
    return const AssetImage('assets/images/onboarding_archway_sun.jpg');
  } else {
    if (!kIsWeb && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) return FileImage(file);
    }
    return const AssetImage('assets/images/onboarding_archway_sun.jpg');
  }
}

// =============================================================================
// MAIN VISION BOARD TAB
// =============================================================================
class VisionBoardTab extends StatefulWidget {
  const VisionBoardTab({Key? key}) : super(key: key);

  @override
  State<VisionBoardTab> createState() => _VisionBoardTabState();
}

class _VisionBoardTabState extends State<VisionBoardTab> {
  bool _showSavedBoards = false;

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
        leading: !_showSavedBoards
            ? IconButton(
                icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.goldAccent),
                tooltip: 'Manifestation Meditation Mode',
                onPressed: () => _openManifestationModal(context),
              )
            : null,
        actions: [
          if (!_showSavedBoards)
            IconButton(
              icon: const Icon(Icons.wallpaper_rounded, color: AppColors.textPrimary),
              tooltip: 'Export 9:16 Lock Screen Wallpaper',
              onPressed: () => _openWallpaperModal(context),
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
                templates: _templates,
                onExportWallpaper: () => _openWallpaperModal(context),
                onOpenMeditation: () => _openManifestationModal(context),
              ),
      ),
    );
  }

  void _openWallpaperModal(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    if (appProvider.activeVisionBoard.blocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one vision goal first before exporting wallpaper! ✨'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _WallpaperExportModal(),
    );
  }

  void _openManifestationModal(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    if (appProvider.activeVisionBoard.blocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add some vision goals first before starting meditation! ✨'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _ManifestationSlideshowScreen(),
      ),
    );
  }
}


// =============================================================================
// ACTIVE BOARD CANVAS VIEW (WITH DRAG & DROP REORDERING)
// =============================================================================
class _ActiveBoardView extends StatelessWidget {
  final List<String> templates;
  final VoidCallback onExportWallpaper;
  final VoidCallback onOpenMeditation;

  const _ActiveBoardView({
    Key? key,
    required this.templates,
    required this.onExportWallpaper,
    required this.onOpenMeditation,
  }) : super(key: key);

  int _getTargetCount(String template) {
    switch (template) {
      case 'Single Hero':
        return 1;
      case '2 Blocks':
        return 2;
      case '4 Blocks':
        return 4;
      case '6 Blocks':
        return 6;
      case '8 Blocks':
        return 8;
      case 'Minimal Layout':
        return 4;
      default:
        return 4;
    }
  }

  int _getCrossAxisCount(String template) {
    if (template == 'Single Hero' || template == '2 Blocks') return 1;
    return 2;
  }

  double _getAspectRatio(String template) {
    if (template == 'Single Hero') return 1.35;
    if (template == '2 Blocks') return 1.55;
    if (template == 'Minimal Layout') return 0.95;
    return 0.82;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final activeBoard = appProvider.activeVisionBoard;
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);
    final targetCount = _getTargetCount(activeBoard.template);
    final displayBlocks = activeBoard.blocks.take(targetCount).toList();
    final totalSlots = targetCount;

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

        // Grid Area with Drag & Drop Reordering
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(activeBoard.template),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: _getAspectRatio(activeBoard.template),
              ),
              itemCount: totalSlots,
              itemBuilder: (ctx, i) {
                if (i < displayBlocks.length) {
                  final block = displayBlocks[i];
                  return DragTarget<int>(
                    onWillAcceptWithDetails: (details) => details.data != i,
                    onAcceptWithDetails: (details) {
                      appProvider.reorderGoalBlocks(details.data, i);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovered = candidateData.isNotEmpty;
                      final card = _GoalCard(block: block, index: i);

                      return LongPressDraggable<int>(
                        data: i,
                        delay: const Duration(milliseconds: 250),
                        hapticFeedbackOnStart: true,
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: 170,
                            height: 200,
                            child: Opacity(
                              opacity: 0.9,
                              child: card,
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: card,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            border: isHovered
                                ? Border.all(color: accent, width: 2.5)
                                : null,
                          ),
                          child: card,
                        ),
                      );
                    },
                  );
                } else {
                  return _EmptyGoalSlot(
                    slotNumber: i + 1,
                    onTap: () => _addNewBlock(context, slotNumber: i + 1),
                  );
                }
              },
            ),
          ),
        ),

        // Bottom Editor Actions Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionBtn(
                icon: Icons.add_photo_alternate_rounded,
                label: 'Add Goal',
                color: accent,
                onTap: () => _addNewBlock(context),
              ),
              _buildActionBtn(
                icon: Icons.auto_awesome_rounded,
                label: 'Visualize',
                color: AppColors.goldAccent,
                onTap: onOpenMeditation,
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
                label: 'Clear',
                color: AppColors.textSecondary,
                onTap: () => _confirmClearAll(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addNewBlock(BuildContext context, {int? slotNumber}) {
    final appProvider = context.read<AppProvider>();
    final newBlock = GoalBlock(
      id: 'gb_${DateTime.now().millisecondsSinceEpoch}',
      title: slotNumber != null ? 'Goal #$slotNumber' : 'My New Goal',
      category: 'Mindset',
      bgImageUrl: 'assets/images/onboarding_moon_clouds.jpg',
      tintValue: 0xFF8A85A0,
      quote: 'I have the courage, calm and focus to manifest this dream into reality.',
      targetDate: DateFormat('MMM yyyy').format(DateTime.now().add(const Duration(days: 90))),
      cardStyle: 'glass',
      isManifested: false,
    );
    appProvider.addGoalBlock(newBlock);
    showDialog(
      context: context,
      builder: (_) => _EditGoalModal(block: newBlock),
    );
  }

  void _showSaveBoardDialog(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final controller = TextEditingController(
      text: 'Vision Board ${DateFormat('MMM yyyy').format(DateTime.now())}',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
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
                fillColor: AppColors.surfaceElevated,
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
        backgroundColor: AppColors.background,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EMPTY GOAL SLOT WIDGET
// =============================================================================
class _EmptyGoalSlot extends StatelessWidget {
  final int slotNumber;
  final VoidCallback onTap;

  const _EmptyGoalSlot({
    Key? key,
    required this.slotNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accent.withOpacity(0.35),
            width: 1.5,
          ),
          color: AppColors.surfaceElevated.withOpacity(0.55),
        ),
        padding: const EdgeInsets.all(14),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: accent, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Goal #$slotNumber',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Tap to create',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// =============================================================================
// GOAL CARD WIDGET (4 DISTINCT AESTHETIC STYLES + MANIFESTED BADGE)
// =============================================================================
class _GoalCard extends StatelessWidget {
  final GoalBlock block;
  final int? index;
  final bool isPreview;

  const _GoalCard({
    Key? key,
    required this.block,
    this.index,
    this.isPreview = false,
  }) : super(key: key);

  String _formatMilestoneCountdown(String target) {
    if (target.isEmpty) return '';
    try {
      final parsed = DateTime.tryParse(target);
      if (parsed != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final targetDate = DateTime(parsed.year, parsed.month, parsed.day);
        final diff = targetDate.difference(today).inDays;
        if (diff > 0) return '${diff}d left';
        if (diff == 0) return 'Today!';
        return 'Achieved';
      }
    } catch (_) {}
    return target;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);

    Widget cardContent;
    switch (block.cardStyle) {
      case 'polaroid':
        cardContent = _buildPolaroidCard(context, accent);
        break;
      case 'bold':
        cardContent = _buildBoldEditorialCard(context, accent);
        break;
      case 'minimal':
        cardContent = _buildMinimalCard(context, accent);
        break;
      case 'glass':
      default:
        cardContent = _buildGlassCard(context, accent);
        break;
    }

    if (isPreview) return cardContent;

    return GestureDetector(
      onTap: () => _openEditModal(context),
      onLongPress: () => _showQuickMenu(context),
      child: cardContent,
    );
  }

  // 1. MODERN GLASS STYLE
  Widget _buildGlassCard(BuildContext context, Color accent) {
    final countdown = _formatMilestoneCountdown(block.targetDate);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: block.isManifested ? AppColors.goldAccent.withOpacity(0.8) : AppColors.border,
          width: block.isManifested ? 1.8 : 1.0,
        ),
        boxShadow: block.isManifested
            ? [
                BoxShadow(
                  color: AppColors.goldAccent.withOpacity(0.22),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
        image: DecorationImage(
          image: resolveGoalImageProvider(block.bgImageUrl),
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
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                if (block.isManifested)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 11, color: Colors.black),
                        const SizedBox(width: 3),
                        Text(
                          'Manifested',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                      ],
                    ),
                  )
                else if (countdown.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.goldAccent.withOpacity(0.6), width: 0.8),
                    ),
                    child: Text(
                      countdown,
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (block.quote.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '"${block.quote}"',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. RETRO POLAROID STYLE
  Widget _buildPolaroidCard(BuildContext context, Color accent) {
    final countdown = _formatMilestoneCountdown(block.targetDate);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: block.isManifested ? AppColors.goldAccent : const Color(0xFFE4DFD5),
          width: block.isManifested ? 2.0 : 1.0,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inner Photo Area
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: resolveGoalImageProvider(block.bgImageUrl),
                    fit: BoxFit.cover,
                    color: block.tint.withOpacity(0.2),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                // Tape effect or manifested seal
                if (block.isManifested)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '✨ Done',
                        style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Bottom Polaroid Caption Chin
          Text(
            block.title,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1E24),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                block.category.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF7A7870),
                ),
              ),
              if (countdown.isNotEmpty)
                Text(
                  countdown,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB57D06),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. BOLD EDITORIAL STYLE
  Widget _buildBoldEditorialCard(BuildContext context, Color accent) {
    final countdown = _formatMilestoneCountdown(block.targetDate);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: resolveGoalImageProvider(block.bgImageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.45),
            BlendMode.darken,
          ),
        ),
        border: Border.all(
          color: block.isManifested ? AppColors.goldAccent : Colors.white24,
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.85),
              Colors.transparent,
              Colors.black.withOpacity(0.92),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    block.category.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Colors.white),
                  ),
                ),
                if (block.isManifested)
                  const Icon(Icons.verified_rounded, color: AppColors.goldAccent, size: 18)
                else if (countdown.isNotEmpty)
                  Text(
                    countdown,
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.goldAccent),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (block.quote.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    block.quote,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 4. FINE MINIMAL STYLE
  Widget _buildMinimalCard(BuildContext context, Color accent) {
    final countdown = _formatMilestoneCountdown(block.targetDate);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: block.isManifested ? AppColors.goldAccent : Colors.white12,
          width: 0.8,
        ),
        image: DecorationImage(
          image: resolveGoalImageProvider(block.bgImageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.62),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                block.category.toLowerCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                  color: Colors.white60,
                ),
              ),
              if (block.isManifested)
                const Text('✨', style: TextStyle(fontSize: 14))
              else if (countdown.isNotEmpty)
                Text(
                  countdown,
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.white70),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (block.quote.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  block.quote,
                  style: GoogleFonts.inter(fontSize: 9.5, color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _openEditModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditGoalModal(block: block),
    );
  }

  void _showQuickMenu(BuildContext context) {
    final appProvider = context.read<AppProvider>();

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
              leading: Icon(
                block.isManifested ? Icons.undo_rounded : Icons.auto_awesome_rounded,
                color: AppColors.goldAccent,
              ),
              title: Text(block.isManifested ? 'Mark as In Progress' : 'Mark as Manifested ✨'),
              onTap: () {
                appProvider.toggleGoalManifested(block.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Delete This Block', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                appProvider.deleteGoalBlock(block.id);
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
// EDIT GOAL MODAL (WYSIWYG PREVIEW, STYLES, 66+ PACKS, PERSISTENT PHOTOS)
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
  late String _cardStyle;
  late bool _isManifested;
  String _selectedPack = 'Abundance & Wealth';

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

  final List<Map<String, String>> _styleOptions = [
    {'id': 'glass', 'label': 'Modern Glass 🪟'},
    {'id': 'polaroid', 'label': 'Retro Polaroid 📷'},
    {'id': 'bold', 'label': 'Bold Editorial 📰'},
    {'id': 'minimal', 'label': 'Fine Minimal 🌿'},
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.block.title);
    _quoteCtrl = TextEditingController(text: widget.block.quote);
    _targetDateCtrl = TextEditingController(text: widget.block.targetDate);
    _category = widget.block.category;
    _bgImageUrl = widget.block.bgImageUrl;
    _tintValue = widget.block.tintValue;
    _cardStyle = widget.block.cardStyle;
    _isManifested = widget.block.isManifested;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quoteCtrl.dispose();
    _targetDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCustomPhoto(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 88,
      );
      if (file != null && mounted) {
        final appProvider = context.read<AppProvider>();
        final savedPath = await appProvider.saveCustomGoalImage(file);
        setState(() {
          _bgImageUrl = savedPath;
        });
      }
    } catch (e) {
      debugPrint("Photo picker error: $e");
    }
  }

  Future<void> _selectDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 90)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.goldAccent,
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _targetDateCtrl.text = DateFormat('MMM d, yyyy').format(picked);
      });
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

    final previewBlock = widget.block.copyWith(
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Goal Title',
      quote: _quoteCtrl.text.trim(),
      category: _category,
      bgImageUrl: _bgImageUrl,
      tintValue: _tintValue,
      targetDate: _targetDateCtrl.text.trim(),
      cardStyle: _cardStyle,
      isManifested: _isManifested,
    );

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customize Goal 🎯',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                    tooltip: 'Delete Block',
                    onPressed: () {
                      appProvider.deleteGoalBlock(widget.block.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // LIVE WYSIWYG PREVIEW CARD
              Center(
                child: Column(
                  children: [
                    Text('LIVE CARD PREVIEW', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 175,
                      height: 200,
                      child: _GoalCard(block: previewBlock, isPreview: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CARD STYLE SELECTOR
              Text('Card Aesthetic Style', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _styleOptions.map((opt) {
                  final isSel = opt['id'] == _cardStyle;
                  return ChoiceChip(
                    label: Text(opt['label']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSel ? Colors.white : AppColors.textPrimary)),
                    selected: isSel,
                    selectedColor: accent,
                    backgroundColor: AppColors.surfaceElevated,
                    onSelected: (val) {
                      if (val) setState(() => _cardStyle = opt['id']!);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // MANIFESTED STATUS SWITCH
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isManifested ? AppColors.goldAccent.withOpacity(0.6) : AppColors.border),
                ),
                child: SwitchListTile(
                  title: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: _isManifested ? AppColors.goldAccent : AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Mark as Manifested ✨',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    _isManifested ? 'Goal achieved! Celebrating your manifestation.' : 'Turn on when this dream becomes your reality.',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  value: _isManifested,
                  activeColor: AppColors.goldAccent,
                  onChanged: (val) => setState(() => _isManifested = val),
                ),
              ),
              const SizedBox(height: 16),

              // GOAL TITLE
              TextField(
                controller: _titleCtrl,
                onChanged: (_) => setState(() {}),
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

              // AFFIRMATIVE QUOTE
              TextField(
                controller: _quoteCtrl,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Affirmative Manifestation Quote',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _openAffirmationPicker,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.goldAccent),
                  label: const Text('Affirmation Library Quick-Pick', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldAccent)),
                ),
              ),

              // TARGET DATE / MILESTONE WITH INTERACTIVE DATE PICKER
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _targetDateCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Target Date / Milestone',
                        hintText: 'e.g., Dec 31, 2026',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _selectDatePicker,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: AppColors.goldAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CATEGORY CHIPS
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
              const SizedBox(height: 18),

              // 66+ ASSET PRESET PACK BROWSER & CUSTOM UPLOAD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Artwork & Photo Pack', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library_rounded, color: AppColors.goldAccent, size: 20),
                        tooltip: 'Upload from Gallery',
                        onPressed: () => _pickCustomPhoto(ImageSource.gallery),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_rounded, color: AppColors.goldAccent, size: 20),
                        tooltip: 'Take a Photo',
                        onPressed: () => _pickCustomPhoto(ImageSource.camera),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Pack Theme Tabs
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: curatedAestheticPacks.keys.map((packName) {
                    final isSel = packName == _selectedPack;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(packName, style: TextStyle(fontSize: 10.5, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : AppColors.textPrimary)),
                        selected: isSel,
                        selectedColor: accent,
                        backgroundColor: AppColors.surfaceElevated,
                        onSelected: (val) {
                          if (val) setState(() => _selectedPack = packName);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Pack Artworks Horizontal Carousel
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Upload Custom Button Card
                    GestureDetector(
                      onTap: () => _pickCustomPhoto(ImageSource.gallery),
                      child: Container(
                        width: 76,
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
                            Text('Custom', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),

                    // Pack Presets
                    ...(curatedAestheticPacks[_selectedPack] ?? []).map((item) {
                      final path = item['path']!;
                      final title = item['title']!;
                      final isSel = path == _bgImageUrl;

                      return GestureDetector(
                        onTap: () => setState(() => _bgImageUrl = path),
                        child: Container(
                          width: 76,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSel ? AppColors.goldAccent : Colors.transparent, width: 2.5),
                            image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                            ),
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // CARD COLOR ATMOSPHERE TINT SWATCHES
              Text('Card Atmosphere Tint', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
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
                  _buildColorSwatch(0xFF1B4332), // Emerald Forest
                ],
              ),
              const SizedBox(height: 24),

              // SAVE & CANCEL ACTIONS
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
                          cardStyle: _cardStyle,
                          isManifested: _isManifested,
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
// WALLPAPER EXPORT MODAL (UNCLIPPED 9:16 HIGH-RES EXPORT & LIVE PREVIEW)
// =============================================================================
class _WallpaperExportModal extends StatefulWidget {
  const _WallpaperExportModal({Key? key}) : super(key: key);

  @override
  State<_WallpaperExportModal> createState() => _WallpaperExportModalState();
}

class _WallpaperExportModalState extends State<_WallpaperExportModal> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportWallpaper(VisionBoard board) async {
    setState(() => _isExporting = true);
    try {
      // Small delay to allow boundary rendering if needed
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Canvas render boundary not found');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to convert canvas to PNG');

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final filename = 'avan_vision_wallpaper_${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await exportWallpaperImage(pngBytes, filename);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result != null
                  ? 'Wallpaper ready! $result ✨ Set as your lock screen.'
                  : 'Wallpaper generated successfully! ✨',
            ),
            backgroundColor: AppColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Wallpaper export error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _copyBoardAffirmations(VisionBoard board) {
    final text = StringBuffer();
    text.writeln('✨ ${board.title.toUpperCase()} ✨');
    text.writeln('----------------------------------------');
    for (final b in board.blocks) {
      text.writeln('• ${b.title} [${b.category}]');
      if (b.quote.isNotEmpty) text.writeln('  "${b.quote}"');
      if (b.targetDate.isNotEmpty) text.writeln('  Target: ${b.targetDate}');
      text.writeln();
    }
    Clipboard.setData(ClipboardData(text: text.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Affirmation goals copied to clipboard! ✨'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildWallpaperCanvas(VisionBoard board, {required bool isHighRes}) {
    final blocks = board.blocks;

    return Container(
      width: isHighRes ? 1080 : 320,
      height: isHighRes ? 1920 : (320 * 16 / 9),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0A14), Color(0xFF14142B), Color(0xFF0B0B12)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isHighRes ? 48 : 14,
        vertical: isHighRes ? 72 : 20,
      ),
      child: Column(
        children: [
          // Top Header
          Text(
            'AVAN MANIFESTATION STUDIO',
            style: GoogleFonts.inter(
              fontSize: isHighRes ? 22 : 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              color: AppColors.goldAccent,
            ),
          ),
          SizedBox(height: isHighRes ? 12 : 4),
          Text(
            board.title.toUpperCase(),
            style: GoogleFonts.cormorantGaramond(
              fontSize: isHighRes ? 34 : 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isHighRes ? 16 : 6),
          Container(
            width: isHighRes ? 120 : 36,
            height: isHighRes ? 2 : 1,
            color: AppColors.goldAccent.withOpacity(0.6),
          ),
          SizedBox(height: isHighRes ? 32 : 12),

          // Cards Grid (Unclipped)
          Expanded(
            child: blocks.isEmpty
                ? Center(
                    child: Text(
                      'No goals added yet',
                      style: TextStyle(color: Colors.white54, fontSize: isHighRes ? 24 : 11),
                    ),
                  )
                : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: isHighRes ? 24 : 8,
                      mainAxisSpacing: isHighRes ? 24 : 8,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: blocks.length.clamp(0, 8),
                    itemBuilder: (ctx, i) {
                      final b = blocks[i];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isHighRes ? 24 : 10),
                          border: Border.all(color: Colors.white24, width: isHighRes ? 1.5 : 0.8),
                          image: DecorationImage(
                            image: resolveGoalImageProvider(b.bgImageUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              b.tint.withOpacity(0.35),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isHighRes ? 24 : 10),
                            gradient: const LinearGradient(
                              colors: [Colors.black54, Colors.transparent, Colors.black87],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          padding: EdgeInsets.all(isHighRes ? 18 : 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: isHighRes ? 10 : 4, vertical: isHighRes ? 4 : 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(isHighRes ? 10 : 4),
                                    ),
                                    child: Text(
                                      b.category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: isHighRes ? 12 : 6,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (b.isManifested)
                                    Icon(Icons.star_rounded, color: AppColors.goldAccent, size: isHighRes ? 22 : 9),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.title,
                                    style: TextStyle(
                                      fontSize: isHighRes ? 18 : 7.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.15,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (b.quote.isNotEmpty) ...[
                                    SizedBox(height: isHighRes ? 6 : 2),
                                    Text(
                                      '"${b.quote}"',
                                      style: GoogleFonts.cormorantGaramond(
                                        fontSize: isHighRes ? 15 : 6.5,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white.withOpacity(0.85),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Watermark & Manifestation Seal
          SizedBox(height: isHighRes ? 24 : 10),
          Text(
            '✨ What you hold in your mind consistently becomes your reality.',
            style: GoogleFonts.cormorantGaramond(
              fontSize: isHighRes ? 20 : 8,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isHighRes ? 8 : 4),
          Text(
            'AVAN • LIVING WITH INTENT',
            style: GoogleFonts.inter(
              fontSize: isHighRes ? 13 : 6,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final activeBoard = appProvider.activeVisionBoard;
    final accent = AppColors.accentForMode(appProvider.isGrowthMode);

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Offscreen render canvas for full 3x crisp 9:16 export
              Offstage(
                offstage: true,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: _buildWallpaperCanvas(activeBoard, isHighRes: true),
                ),
              ),

              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lock Screen Wallpaper 📱',
                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Full 9:16 unclipped HD wallpaper tailored for phone lock screens.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // On-Screen Scaled 9:16 Preview
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: _buildWallpaperCanvas(activeBoard, isHighRes: false),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Export Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyBoardAffirmations(activeBoard),
                      icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.textPrimary),
                      label: const Text('Copy Text', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : () => _exportWallpaper(activeBoard),
                      icon: _isExporting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                      label: Text(
                        _isExporting ? 'Exporting...' : 'Export Wallpaper',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
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
  }
}


// =============================================================================
// SAVED BOARDS GALLERY VIEW (MOSAIC THUMBNAILS, LOAD CONFIRMATION & DUPLICATE)
// =============================================================================
class _SavedBoardsView extends StatelessWidget {
  const _SavedBoardsView({Key? key}) : super(key: key);

  Widget _buildMosaicThumbnail(VisionBoard board) {
    final blocks = board.blocks.take(4).toList();

    if (blocks.isEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.dashboard_rounded, color: AppColors.goldAccent, size: 24),
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 1.5,
            mainAxisSpacing: 1.5,
          ),
          itemCount: 4,
          itemBuilder: (ctx, i) {
            if (i < blocks.length) {
              return Image(
                image: resolveGoalImageProvider(blocks[i].bgImageUrl),
                fit: BoxFit.cover,
              );
            }
            return Container(color: AppColors.surfaceElevated);
          },
        ),
      ),
    );
  }

  void _confirmLoadBoard(BuildContext context, VisionBoard board) {
    final appProvider = context.read<AppProvider>();
    final hasActiveGoals = appProvider.activeVisionBoard.blocks.isNotEmpty;

    if (!hasActiveGoals) {
      appProvider.loadSavedBoard(board.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded "${board.title}" into active canvas! ✨'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Load Saved Board?'),
        content: Text(
          'Loading "${board.title}" will replace your current active canvas blocks. Make sure you have saved any changes you wish to keep.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              appProvider.loadSavedBoard(board.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Loaded "${board.title}" into active canvas! ✨'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Load Canvas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteBoard(BuildContext context, VisionBoard board) {
    final appProvider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Board Snapshot?'),
        content: Text('Are you sure you want to delete "${board.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              appProvider.deleteSavedBoard(board.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _buildMosaicThumbnail(b),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 3),
                      Text(
                        '${b.blocks.length} Goals • ${b.template} • ${DateFormat('MMM d, yyyy').format(b.lastModified)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_all_rounded, color: AppColors.textSecondary, size: 20),
                  tooltip: 'Duplicate Board',
                  onPressed: () {
                    appProvider.duplicateSavedBoard(b.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Duplicated "${b.title}"! ✨'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser_rounded, color: AppColors.goldAccent, size: 22),
                  tooltip: 'Load into Canvas',
                  onPressed: () => _confirmLoadBoard(context, b),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                  tooltip: 'Delete Board',
                  onPressed: () => _confirmDeleteBoard(context, b),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// MANIFESTATION MEDITATION SLIDESHOW SCREEN (FULLSCREEN IMMERSION + 528HZ AUDIO)
// =============================================================================
class _ManifestationSlideshowScreen extends StatefulWidget {
  const _ManifestationSlideshowScreen({Key? key}) : super(key: key);

  @override
  State<_ManifestationSlideshowScreen> createState() => _ManifestationSlideshowScreenState();
}

class _ManifestationSlideshowScreenState extends State<_ManifestationSlideshowScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final AudioPlayer _ambientAudioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;
  bool _isAutoPlaying = true;
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Subtle 4-second breathing oscillation: expands 1.0 -> 1.06 smoothly
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _startAutoAdvance();
    _startAmbientAudio();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted || !_isAutoPlaying) return;
      final appProvider = context.read<AppProvider>();
      final total = appProvider.activeVisionBoard.blocks.length;
      if (total <= 1) return;

      final nextPage = (_currentPage + 1) % total;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  Future<void> _startAmbientAudio() async {
    try {
      final wavBytes = AmbientAudioSynthesizer.getWavBytesForSound(AmbientSound.solfeggio528);
      await _ambientAudioPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientAudioPlayer.setVolume(0.35);
      await _ambientAudioPlayer.play(BytesSource(wavBytes));
      if (mounted) setState(() => _isAudioPlaying = true);
    } catch (e) {
      debugPrint("Meditation ambient audio note: $e");
    }
  }

  Future<void> _toggleAudio() async {
    if (_isAudioPlaying) {
      await _ambientAudioPlayer.pause();
      if (mounted) setState(() => _isAudioPlaying = false);
    } else {
      await _startAmbientAudio();
    }
  }

  void _toggleAutoPlay() {
    setState(() {
      _isAutoPlaying = !_isAutoPlaying;
      if (_isAutoPlaying) {
        _startAutoAdvance();
      } else {
        _autoAdvanceTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pulseController.dispose();
    _pageController.dispose();
    _ambientAudioPlayer.stop();
    _ambientAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final blocks = appProvider.activeVisionBoard.blocks;

    if (blocks.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF07070D),
        body: Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label: const Text('No goals to visualize. Tap to return.', style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07070D),
      body: SafeArea(
        child: Stack(
          children: [
            // Slide Page View
            PageView.builder(
              controller: _pageController,
              itemCount: blocks.length,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemBuilder: (ctx, idx) {
                final block = blocks[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Breathing Hero Image Container
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: block.isManifested ? AppColors.goldAccent : Colors.white24,
                                width: block.isManifested ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (block.isManifested ? AppColors.goldAccent : block.tint).withOpacity(0.3),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                ),
                              ],
                              image: DecorationImage(
                                image: resolveGoalImageProvider(block.bgImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Category & Manifested Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              block.category.toUpperCase(),
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white70),
                            ),
                          ),
                          if (block.isManifested) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.goldAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.black),
                                  SizedBox(width: 4),
                                  Text(
                                    'MANIFESTED',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Goal Title
                      Text(
                        block.title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // Affirmative Quote
                      if (block.quote.isNotEmpty)
                        Text(
                          '"${block.quote}"',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 14),

                      // Meditative Breathing Guidance Prompt
                      Text(
                        'Inhale slowly... Feel the gratitude of this reality as already yours.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.goldAccent.withOpacity(0.85),
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Top Control Bar
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 26),
                    tooltip: 'Exit Meditation',
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      '${_currentPage + 1} of ${blocks.length}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isAudioPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: _isAudioPlaying ? AppColors.goldAccent : Colors.white60,
                        ),
                        tooltip: '528Hz Solfeggio Healing Sound',
                        onPressed: _toggleAudio,
                      ),
                      IconButton(
                        icon: Icon(
                          _isAutoPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                        ),
                        tooltip: _isAutoPlaying ? 'Pause Slideshow' : 'Resume Auto-Play',
                        onPressed: _toggleAutoPlay,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Navigation Arrows & Progress Dots
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 30),
                    onPressed: _currentPage > 0
                        ? () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut)
                        : null,
                  ),
                  Row(
                    children: List.generate(blocks.length, (i) {
                      final isSel = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isSel ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.goldAccent : Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 30),
                    onPressed: _currentPage < blocks.length - 1
                        ? () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
