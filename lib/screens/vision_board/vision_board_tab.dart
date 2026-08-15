import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';

class VisionBoardTab extends StatelessWidget {
  const VisionBoardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisionBoardState(),
      child: const VisionBoardContent(),
    );
  }
}

class GoalBlock {
  String id;
  String title;
  String category;
  String bgImageUrl;
  Color tint;
  String quote;

  GoalBlock({
    required this.id,
    required this.title,
    required this.category,
    required this.bgImageUrl,
    required this.tint,
    required this.quote,
  });
}

class VisionBoardState extends ChangeNotifier {
  String activeTemplate = '4 Blocks';
  bool showSavedBoards = false;

  final List<String> templates = [
    '2 Blocks',
    '4 Blocks',
    '6 Blocks',
    '8 Blocks',
    'Minimal Layout',
    'Free Layout'
  ];

  final List<String> categories = [
    'Mindset',
    'Wealth',
    'Health',
    'Relationships',
    'Career'
  ];

  final Map<String, String> backgroundLibrary = {
    'Archway Sun': 'https://images.unsplash.com/photo-1596766472421-2e6b20892019?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    'Girl Profile': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    'Moon & Clouds': 'https://images.unsplash.com/photo-1532767153582-b1a0e5145009?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    'Featured Meditation': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
    'Sleep Night Sky': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
  };

  List<GoalBlock> activeBlocks = [
    GoalBlock(
      id: '1',
      title: 'Inner Peace & Wealth',
      category: 'Mindset',
      bgImageUrl: 'https://images.unsplash.com/photo-1596766472421-2e6b20892019?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      tint: AppColors.tanAccent,
      quote: 'I am a magnet for abundance.',
    ),
    GoalBlock(
      id: '2',
      title: 'Daily Meditation Habit',
      category: 'Health',
      bgImageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      tint: AppColors.nudeAccent,
      quote: 'Peace is my priority.',
    ),
  ];

  final List<String> savedBoards = [
    'Morning Focus 2026',
    'Abundance & Serenity',
    'Ideal Self'
  ];

  void setTemplate(String t) {
    activeTemplate = t;
    notifyListeners();
  }

  void toggleSavedBoards(bool val) {
    showSavedBoards = val;
    notifyListeners();
  }

  void addBlock() {
    activeBlocks.add(
      GoalBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Goal',
        category: 'Mindset',
        bgImageUrl: backgroundLibrary['Moon & Clouds']!,
        tint: AppColors.softBeige,
        quote: 'Believe in yourself.',
      ),
    );
    notifyListeners();
  }

  void updateBlock(String id, GoalBlock updated) {
    final index = activeBlocks.indexWhere((b) => b.id == id);
    if (index != -1) {
      activeBlocks[index] = updated;
      notifyListeners();
    }
  }

  void clearAll() {
    activeBlocks.clear();
    notifyListeners();
  }

  int getCrossAxisCount() {
    if (activeTemplate == '2 Blocks' || activeTemplate == '4 Blocks' || activeTemplate == 'Minimal Layout') {
      return 2;
    }
    if (activeTemplate == '6 Blocks' || activeTemplate == '8 Blocks') {
      return 2;
    }
    return 1;
  }
}

class VisionBoardContent extends StatelessWidget {
  const VisionBoardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VisionBoardState>();
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vision Board',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Active Board')),
                      ButtonSegment(value: true, label: Text('Saved Boards')),
                    ],
                    selected: {state.showSavedBoards},
                    onSelectionChanged: (val) => state.toggleSavedBoards(val.first),
                    style: SegmentedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      selectedBackgroundColor: AppColors.accentForMode(appProvider.isGrowthMode),
                      selectedForegroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: state.showSavedBoards ? const SavedBoardsView() : const ActiveBoardView(),
      ),
    );
  }
}

class SavedBoardsView extends StatelessWidget {
  const SavedBoardsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VisionBoardState>();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.savedBoards.length,
      itemBuilder: (ctx, i) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: AppColors.surfaceElevated,
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: const Icon(Icons.dashboard_customize_rounded, color: AppColors.goldAccent),
            title: Text(
              state.savedBoards[i],
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
          ),
        );
      },
    );
  }
}

class ActiveBoardView extends StatelessWidget {
  const ActiveBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VisionBoardState>();

    return Column(
      children: [
        // Template Selection Header
        SizedBox(
          height: 60,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: state.templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final t = state.templates[i];
              final isSelected = t == state.activeTemplate;
              return ChoiceChip(
                label: Text(
                  t,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (val) {
                  if (val) state.setTemplate(t);
                },
                selectedColor: AppColors.accentForMode(context.watch<AppProvider>().isGrowthMode),
                backgroundColor: AppColors.surfaceElevated,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppColors.border,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            },
          ),
        ),
        
        // Active Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: state.activeBlocks.isEmpty
                ? const Center(
                    child: Text(
                      'No goals yet. Add a block to start.',
                      style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
                    ),
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: state.getCrossAxisCount(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: state.activeBlocks.length,
                    itemBuilder: (ctx, i) {
                      final block = state.activeBlocks[i];
                      return GoalCard(block: block);
                    },
                  ),
          ),
        ),

        // Editor Actions Bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionBtn(
                context: context,
                icon: Icons.add_rounded,
                label: 'Add Block',
                iconColor: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode),
                onTap: () => state.addBlock(),
              ),
              _buildActionBtn(
                context: context,
                icon: Icons.save_rounded,
                label: 'Save Board',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Board saved successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              _buildActionBtn(
                context: context,
                icon: Icons.delete_outline_rounded,
                label: 'Clear All',
                onTap: () => state.clearAll(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor ?? AppColors.iconColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final GoalBlock block;
  const GoalCard({Key? key, required this.block}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showEditDialog(context, block),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: block.tint.withOpacity(0.3),
          image: DecorationImage(
            image: NetworkImage(block.bgImageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              block.tint.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Colors.black54, Colors.transparent, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  block.category,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    block.title,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    block.quote,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
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

  void _showEditDialog(BuildContext context, GoalBlock block) {
    showDialog(
      context: context,
      builder: (_) => EditGoalDialog(
        block: block,
        state: context.read<VisionBoardState>(),
      ),
    );
  }
}

class EditGoalDialog extends StatefulWidget {
  final GoalBlock block;
  final VisionBoardState state;

  const EditGoalDialog({Key? key, required this.block, required this.state}) : super(key: key);

  @override
  _EditGoalDialogState createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late TextEditingController _titleCtrl;
  late TextEditingController _quoteCtrl;
  late String _category;
  late String _bgKey;
  late Color _tint;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.block.title);
    _quoteCtrl = TextEditingController(text: widget.block.quote);
    _category = widget.block.category;
    
    // Find bgKey from URL
    _bgKey = widget.state.backgroundLibrary.entries
        .firstWhere((e) => e.value == widget.block.bgImageUrl, orElse: () => widget.state.backgroundLibrary.entries.first)
        .key;
    _tint = widget.block.tint;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Goal Block',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                labelStyle: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quoteCtrl,
              decoration: InputDecoration(
                labelText: 'Affirmative Quote',
                labelStyle: const TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            const Text('Category', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.state.categories.map((c) {
                final isSelected = c == _category;
                return ChoiceChip(
                  label: Text(c, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: isSelected ? Colors.white : AppColors.textPrimary)),
                  selected: isSelected,
                  selectedColor: AppColors.accentForMode(context.watch<AppProvider>().isGrowthMode),
                  backgroundColor: AppColors.surfaceElevated,
                  onSelected: (val) {
                    if (val) setState(() => _category = c);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Background Image', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.state.backgroundLibrary.entries.map((e) {
                  final isSelected = e.key == _bgKey;
                  return GestureDetector(
                    onTap: () => setState(() => _bgKey = e.key),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.goldAccent : Colors.transparent,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(e.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Card Tint', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                _buildColorTint(AppColors.tanAccent),
                _buildColorTint(AppColors.nudeAccent),
                _buildColorTint(AppColors.goldAccent),
                _buildColorTint(AppColors.greenAccent),
                _buildColorTint(AppColors.buttonDark),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final updated = GoalBlock(
                        id: widget.block.id,
                        title: _titleCtrl.text,
                        category: _category,
                        bgImageUrl: widget.state.backgroundLibrary[_bgKey]!,
                        tint: _tint,
                        quote: _quoteCtrl.text,
                      );
                      widget.state.updateBlock(widget.block.id, updated);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentForMode(context.read<AppProvider>().isGrowthMode),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorTint(Color color) {
    final isSelected = _tint == color;
    return GestureDetector(
      onTap: () => setState(() => _tint = color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}
