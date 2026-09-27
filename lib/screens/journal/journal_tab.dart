import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({Key? key}) : super(key: key);

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyFavorites = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isGrowth = appProvider.isGrowthMode;
    final accent = AppColors.accentForMode(isGrowth);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final filteredEntries = appProvider.journalEntries.where((entry) {
      final matchesSearch = entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            entry.body.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorites = !_showOnlyFavorites || entry.isFavorite;
      return matchesSearch && matchesFavorites;
    }).toList();

    final bool hasAnyEntries = appProvider.journalEntries.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Daily Journal',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.25)),
              ),
              child: Icon(Icons.edit_rounded, color: accent, size: 18),
            ),
            tooltip: 'New Reflection',
            onPressed: () => _showAddEntryDialog(context, appProvider),
          ),
          const SizedBox(width: 12),
        ],
      ),
      // Only show FAB when there are existing entries; when empty, the center CTA is used
      floatingActionButton: hasAnyEntries
          ? Padding(
              padding: EdgeInsets.only(bottom: 96.0 + bottomInset),
              child: FloatingActionButton.extended(
                backgroundColor: accent,
                elevation: 4,
                highlightElevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                onPressed: () => _showAddEntryDialog(context, appProvider),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'New Entry',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Section title & Favorites filter pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'REFLECTIONS & MOOD TRACKER',
                    style: AppTextStyles.sectionTitle,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _showOnlyFavorites
                            ? AppColors.goldAccent.withOpacity(0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showOnlyFavorites
                              ? AppColors.goldAccent.withOpacity(0.6)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showOnlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: _showOnlyFavorites ? AppColors.goldAccent : AppColors.textSecondary,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _showOnlyFavorites ? FontWeight.w600 : FontWeight.w500,
                              color: _showOnlyFavorites ? AppColors.goldAccent : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search capsule bar
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search reflections by keyword...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textMuted),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Main content area
              Expanded(
                child: filteredEntries.isEmpty
                    ? _buildEmptyState(context, appProvider, accent, hasAnyEntries)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 110 + bottomInset),
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          return _buildJournalCard(context, entry, appProvider, accent);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppProvider appProvider, Color accent, bool hasAnyEntries) {
    if (hasAnyEntries) {
      // Empty search/filter result
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.search_off_rounded, size: 38, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              const Text(
                'No matching reflections',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try adjusting your search query or toggling off the favorites filter.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Fresh empty journal state
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Center(
                child: Icon(Icons.menu_book_rounded, size: 40, color: accent),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No journal entries yet',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture your inner thoughts, track your emotional shifts, and ground yourself in your daily journey.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: () => _showAddEntryDialog(context, appProvider),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              label: const Text(
                'Write First Reflection',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(
      BuildContext context, JournalEntry entry, AppProvider appProvider, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        entry.mood,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => appProvider.toggleJournalFavorite(entry.id),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: entry.isFavorite ? AppColors.goldAccent : AppColors.textMuted,
                          size: 19,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _confirmDeleteEntry(context, appProvider, entry.id),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFD9776E),
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, yyyy • h:mm a').format(entry.date),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              entry.body,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteEntry(BuildContext context, AppProvider appProvider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Reflection', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to remove this journal entry?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              appProvider.deleteJournalEntry(id);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFD9776E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context, AppProvider appProvider) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    String selectedMood = 'Peaceful';

    final List<Map<String, String>> moods = [
      {'label': 'Happy', 'emoji': '😊'},
      {'label': 'Peaceful', 'emoji': '😌'},
      {'label': 'Focused', 'emoji': '🧐'},
      {'label': 'Anxious', 'emoji': '😰'},
      {'label': 'Motivated', 'emoji': '💪'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            final isGrowth = appProvider.isGrowthMode;
            final accent = AppColors.accentForMode(isGrowth);

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Write Journal Entry',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Title of your reflection',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'What is present with you right now?',
                        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'How are you feeling?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: moods.map((mood) {
                          final isSelected = selectedMood == mood['label'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: GestureDetector(
                              onTap: () {
                                setStateModal(() {
                                  selectedMood = mood['label']!;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? accent : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? accent : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(mood['emoji']!, style: const TextStyle(fontSize: 15)),
                                    const SizedBox(width: 6),
                                    Text(
                                      mood['label']!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    CustomButton(
                      text: 'Save Reflection',
                      onPressed: () {
                        final title = titleController.text.trim();
                        final body = bodyController.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a title for your reflection ✍️'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        if (body.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please write your thoughts in the journal entry ✍️'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        appProvider.addJournalEntry(
                          JournalEntry(
                            id: DateTime.now().toString(),
                            title: title,
                            body: body,
                            mood: selectedMood,
                            date: DateTime.now(),
                          ),
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reflection saved to your journal! ✨'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
