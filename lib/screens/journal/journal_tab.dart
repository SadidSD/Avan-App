import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/journal_entry.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({Key? key}) : super(key: key);

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  String _searchQuery = '';
  bool _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    
    final filteredEntries = appProvider.journalEntries.where((entry) {
      final matchesSearch = entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            entry.body.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorites = !_showOnlyFavorites || entry.isFavorite;
      return matchesSearch && matchesFavorites;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Daily Journal',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentForMode(appProvider.isGrowthMode),
        onPressed: () => _showAddEntryDialog(context, appProvider),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'REFLECTIONS & MOOD TRACKER',
                    style: AppTextStyles.sectionTitle,
                  ),
                  IconButton(
                    icon: Icon(
                      _showOnlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _showOnlyFavorites ? AppColors.goldAccent : AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                  )
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search entries...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filteredEntries.isEmpty
                    ? Center(
                        child: Text(
                          appProvider.journalEntries.isEmpty
                              ? 'No journal entries yet. Tap + to write one!'
                              : 'No matching entries found.',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: CustomCard(
                              backgroundColor: AppColors.surfaceElevated,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Chip(
                                            label: Text(entry.mood, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                                            backgroundColor: AppColors.surface,
                                            side: const BorderSide(color: AppColors.border),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                entry.isFavorite = !entry.isFavorite;
                                              });
                                            },
                                            child: Icon(
                                              entry.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                              color: entry.isFavorite ? AppColors.goldAccent : AppColors.textSecondary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () {
                                              appProvider.deleteJournalEntry(entry.id);
                                            },
                                            child: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.body,
                                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Write Journal Entry',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Write your thoughts...',
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'How are you feeling?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: moods.map((mood) {
                          final isSelected = selectedMood == mood['label'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                setStateModal(() {
                                  selectedMood = mood['label']!;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.accentForMode(appProvider.isGrowthMode) : AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.accentForMode(appProvider.isGrowthMode) : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(mood['emoji']!, style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      mood['label']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Save Entry',
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          appProvider.addJournalEntry(
                            JournalEntry(
                              id: DateTime.now().toString(),
                              title: titleController.text,
                              body: bodyController.text,
                              mood: selectedMood,
                              date: DateTime.now(),
                            ),
                          );
                          Navigator.pop(context);
                        }
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
