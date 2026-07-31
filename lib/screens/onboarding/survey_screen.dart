import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import 'loading_screen.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int _step = 0;

  String _goal = 'Boost Confidence';
  String _challenge = 'Overthinking & Self-Doubt';
  String _vision = 'Calm & Confident Mind';
  String _commitment = '10 Min/Day';

  final List<String> _goals = [
    'Boost Confidence',
    'Reduce Stress & Anxiety',
    'Deep Focus & Productivity',
    'Restful Sleep & Peace',
    'Build Wealth Mindset',
    'Stronger Relationships',
  ];

  final List<String> _challenges = [
    'Overthinking & Self-Doubt',
    'Lack of Focus & Procrastination',
    'High Stress & Burnout',
    'Poor Sleep & Night Anxiety',
  ];

  final List<String> _visions = [
    'Calm & Confident Mind',
    'Daily Peak Performance',
    'Unstoppable Motivation & Joy',
  ];

  final List<String> _commitments = [
    '5 Min/Day',
    '10 Min/Day',
    '15 Min/Day',
    '20+ Min/Day',
  ];

  @override
  Widget build(BuildContext context) {
    List<String> options = [];
    String title = '';
    String selectedValue = '';

    if (_step == 0) {
      title = 'What is your primary goal?';
      options = _goals;
      selectedValue = _goal;
    } else if (_step == 1) {
      title = 'What is your biggest challenge?';
      options = _challenges;
      selectedValue = _challenge;
    } else if (_step == 2) {
      title = 'What vision do you have for yourself?';
      options = _visions;
      selectedValue = _vision;
    } else {
      title = 'How much time can you commit daily?';
      options = _commitments;
      selectedValue = _commitment;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
                onPressed: () {
                  setState(() {
                    _step--;
                  });
                },
              )
            : null,
        title: Text(
          'Step ${_step + 1} of 4',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_step + 1) / 4,
                backgroundColor: AppColors.nudeAccent,
                color: AppColors.buttonDark,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final item = options[index];
                    final isSelected = item == selectedValue;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: CustomCard(
                        backgroundColor: isSelected ? AppColors.softBeige : AppColors.cardSurface,
                        onTap: () {
                          setState(() {
                            if (_step == 0) _goal = item;
                            if (_step == 1) _challenge = item;
                            if (_step == 2) _vision = item;
                            if (_step == 3) _commitment = item;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: isSelected ? AppColors.buttonDark : AppColors.tanAccent,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              CustomButton(
                text: _step == 3 ? 'Personalize Journey' : 'Continue',
                onPressed: () {
                  if (_step < 3) {
                    setState(() {
                      _step++;
                    });
                  } else {
                    Provider.of<AppProvider>(context, listen: false).setSurveyAnswers(
                      goal: _goal,
                      challenge: _challenge,
                      vision: _vision,
                      commitment: _commitment,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoadingScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
