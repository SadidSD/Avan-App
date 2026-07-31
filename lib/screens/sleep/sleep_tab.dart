import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_card.dart';
import '../../data/playlists_data.dart';

class SleepTab extends StatelessWidget {
  const SleepTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    final List<Map<String, String>> sleepStories = [
      {'title': 'The Calm Forest', 'duration': '23 min', 'image': 'assets/images/sleep_story_night.jpg'},
      {'title': 'Moonlit Journey', 'duration': '28 min', 'image': 'assets/images/sleep_story_night.jpg'},
      {'title': 'Dreamy Clouds', 'duration': '26 min', 'image': 'assets/images/sleep_story_night.jpg'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
        title: const Text(
          'Sleep',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.timer_outlined, color: AppColors.textPrimary),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sleep Hero Card
              CustomCard(
                backgroundColor: AppColors.softBeige,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Tonight, let's\nsleep better",
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Relax your mind and wake up refreshed.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.nightlight_round, size: 48, color: AppColors.tanAccent),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Sleep Stories Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Sleep Stories',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text('See All', style: TextStyle(fontSize: 13, color: AppColors.tanAccent)),
                ],
              ),
              const SizedBox(height: 14),

              // Sleep Stories Cards Horizontal Scroll
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sleepStories.length,
                  itemBuilder: (context, index) {
                    final story = sleepStories[index];
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 14.0),
                      child: CustomCard(
                        padding: EdgeInsets.zero,
                        onTap: () => audioProvider.openPlaylist(allPlaylists[2], context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                                  child: Image.asset(
                                    story['image']!,
                                    height: 110,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 110,
                                      color: AppColors.sleepDark,
                                      child: const Center(child: Icon(Icons.star, color: Colors.white)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.buttonDark,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story['title']!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    story['duration']!,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
