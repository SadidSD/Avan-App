import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_archetype.dart';
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
  static const int _totalSteps = 5;

  // Selected State
  UserArchetype _primaryArchetype = UserArchetype.careerProfessional;
  final List<String> _selectedSubLevels = [];
  final List<UserArchetype> _secondaryArchetypes = [];
  AffirmationTone _preferredTone = AffirmationTone.empowering;
  double _believabilityPreference = 0.75;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppColors.textPrimary),
                onPressed: () {
                  setState(() {
                    _step--;
                  });
                },
              )
            : null,
        title: Text(
          'Step ${_step + 1} of $_totalSteps',
          style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _totalSteps,
                  backgroundColor: AppColors.border,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.goldAccent),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 24),

              // Title and Subtitle
              _buildHeader(),
              const SizedBox(height: 18),

              // Step Content
              Expanded(
                child: _buildStepContent(),
              ),

              const SizedBox(height: 12),
              // Action Button
              CustomButton(
                text: _step == _totalSteps - 1
                    ? 'Generate My Affirmation Matrix ✨'
                    : 'Continue',
                backgroundColor: AppColors.buttonDark,
                textColor: Colors.white,
                onPressed: _onNextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title = '';
    String subtitle = '';

    switch (_step) {
      case 0:
        title = 'What describes your current chapter?';
        subtitle =
            'Select the primary identity or challenge you want to focus on.';
        break;
      case 1:
        final meta = ArchetypeRegistry.getMetadata(_primaryArchetype);
        title = 'Specify your stage or focus area';
        subtitle =
            'Personalize for your exact experience within ${meta.title}.';
        break;
      case 2:
        title = 'Any intersecting areas to support?';
        subtitle =
            'Select all secondary habits, background, or life areas that apply.';
        break;
      case 3:
        title = 'What affirmation tone works best?';
        subtitle =
            'Choose the voice that feels most resonant and respectful.';
        break;
      case 4:
        title = 'How does your mind react to positive affirmations?';
        subtitle =
            'Science shows believability is essential for neural rewiring.';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildPrimaryArchetypeList();
      case 1:
        return _buildSubLevelList();
      case 2:
        return _buildSecondaryArchetypeList();
      case 3:
        return _buildToneList();
      case 4:
        return _buildBelievabilityList();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Primary Archetype
  Widget _buildPrimaryArchetypeList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: ArchetypeRegistry.allArchetypes.length,
      itemBuilder: (context, index) {
        final meta = ArchetypeRegistry.allArchetypes[index];
        final isSelected = _primaryArchetype == meta.archetype;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: CustomCard(
            backgroundColor: isSelected ? Colors.white : AppColors.surfaceSolid,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            onTap: () {
              setState(() {
                _primaryArchetype = meta.archetype;
                _selectedSubLevels.clear();
              });
            },
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.goldAccent.withOpacity(0.15)
                        : Colors.black.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      meta.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta.shortDescription,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Step 2: Sub-Level Granular Focus
  Widget _buildSubLevelList() {
    final meta = ArchetypeRegistry.getMetadata(_primaryArchetype);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: meta.subLevels.length,
      itemBuilder: (context, index) {
        final sub = meta.subLevels[index];
        final isSelected = _selectedSubLevels.contains(sub);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: CustomCard(
            backgroundColor: isSelected ? Colors.white : AppColors.surfaceSolid,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedSubLevels.remove(sub);
                } else {
                  _selectedSubLevels.add(sub);
                }
              });
            },
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Step 3: Secondary Intersecting Archetypes
  Widget _buildSecondaryArchetypeList() {
    final candidates = ArchetypeRegistry.allArchetypes
        .where((m) => m.archetype != _primaryArchetype)
        .toList();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final meta = candidates[index];
        final isSelected = _secondaryArchetypes.contains(meta.archetype);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: CustomCard(
            backgroundColor: isSelected ? Colors.white : AppColors.surfaceSolid,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _secondaryArchetypes.remove(meta.archetype);
                } else {
                  _secondaryArchetypes.add(meta.archetype);
                }
              });
            },
            child: Row(
              children: [
                Text(meta.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    meta.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Step 4: Affirmation Tone & Modality
  Widget _buildToneList() {
    final tones = [
      {
        'tone': AffirmationTone.empowering,
        'title': 'Empowering & Confident',
        'desc': 'Bold, energizing statements to step into power and courage.',
        'icon': '🔥',
      },
      {
        'tone': AffirmationTone.gentleAndGrounding,
        'title': 'Gentle & Grounding (CBT/Compassion)',
        'desc': 'Process-oriented, believable statements without toxic positivity.',
        'icon': '🌿',
      },
      {
        'tone': AffirmationTone.directAndActionable,
        'title': 'Direct & Action-Driven',
        'desc': 'Straightforward momentum, discipline, and execution focus.',
        'icon': '⚡',
      },
      {
        'tone': AffirmationTone.philosophical,
        'title': 'Philosophical & Stoic',
        'desc': 'Deeper reflection on values, control, and long-term wisdom.',
        'icon': '🏛️',
      },
      {
        'tone': AffirmationTone.simpleAndClear,
        'title': 'Simple, Sensory & Direct (Accessible)',
        'desc': 'Concrete sensory calming and clear capability statements.',
        'icon': '🧩',
      },
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: tones.length,
      itemBuilder: (context, index) {
        final item = tones[index];
        final tone = item['tone'] as AffirmationTone;
        final isSelected = _preferredTone == tone;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: CustomCard(
            backgroundColor: isSelected ? Colors.white : AppColors.surfaceSolid,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            onTap: () {
              setState(() {
                _preferredTone = tone;
              });
            },
            child: Row(
              children: [
                Text(item['icon'] as String, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['desc'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Step 5: Believability & Skepticism Calibration (NEW!)
  Widget _buildBelievabilityList() {
    final options = [
      {
        'val': 0.55,
        'title': 'Energized & Ambitious',
        'subtitle': 'I embrace bold stretch goals and high agency.',
        'icon': '🚀',
      },
      {
        'val': 0.75,
        'title': 'Cautiously Open',
        'subtitle': 'I need realistic, progressive CBT cognitive reframing.',
        'icon': '⚖️',
      },
      {
        'val': 0.92,
        'title': 'Guarded & Sensitive',
        'subtitle': 'My inner critic rejects cheesy statements; I need safe grounding.',
        'icon': '🛡️',
      },
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final opt = options[index];
        final val = opt['val'] as double;
        final isSelected = (_believabilityPreference - val).abs() < 0.05;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: CustomCard(
            backgroundColor: isSelected ? Colors.white : AppColors.surfaceSolid,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            onTap: () {
              setState(() {
                _believabilityPreference = val;
              });
            },
            child: Row(
              children: [
                Text(opt['icon'] as String, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        opt['subtitle'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.goldAccent : AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNextStep() {
    if (_step < _totalSteps - 1) {
      if (_step == 0 && _selectedSubLevels.isEmpty) {
        final meta = ArchetypeRegistry.getMetadata(_primaryArchetype);
        if (meta.subLevels.isNotEmpty) {
          _selectedSubLevels.add(meta.subLevels.first);
        }
      }
      setState(() {
        _step++;
      });
    } else {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.setUserArchetypeProfile(
        primary: [_primaryArchetype],
        secondary: _secondaryArchetypes,
        subLevels: _selectedSubLevels,
        tone: _preferredTone,
        believabilityPreference: _believabilityPreference,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoadingScreen()),
      );
    }
  }
}
