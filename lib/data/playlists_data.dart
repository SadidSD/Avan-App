import '../models/affirmation.dart';
import '../models/playlist.dart';
import '../services/audio_engine_service.dart';
import 'affirmation_library.dart';

final List<Playlist> allPlaylists = [
  // ==========================================
  // FREE PLAYLISTS
  // ==========================================
  Playlist(
    id: 'pl_morning_energy',
    title: 'Morning Energy',
    duration: '10 min',
    category: 'Morning Energy',
    imagePath: 'assets/images/onboarding_archway_sun.jpg',
    isPremium: false,
    defaultAmbientSound: AmbientSound.solfeggio528,
    affirmations: [
      Affirmation(id: 'aff_me_1', quote: 'I wake up today with strength in my heart and clarity in my mind.', category: 'Morning Energy'),
      Affirmation(id: 'aff_me_2', quote: 'My body is rested and my mind is clear, ready to embrace the day.', category: 'Morning Energy'),
      Affirmation(id: 'aff_me_3', quote: 'Today is a blank canvas, and I choose to paint it with vibrant energy.', category: 'Morning Energy'),
      Affirmation(id: 'aff_me_4', quote: 'I am filled with vitality and ready to conquer whatever comes my way.', category: 'Morning Energy'),
      Affirmation(id: 'aff_me_5', quote: 'Every cell in my body vibrates with positive energy and life.', category: 'Morning Energy'),
      Affirmation(id: 'aff_me_6', quote: 'I welcome the sunrise with a grateful heart and an energized spirit.', category: 'Morning Energy'),
      Affirmation(id: 'aff_me_7', quote: 'My energy is limitless, and I channel it into purposeful action.', category: 'Morning Energy'),
      Affirmation(id: 'aff_me_8', quote: 'I radiate enthusiasm and inspire those around me with my positive aura.', category: 'Morning Energy'),
    ],
  ),
  Playlist(
    id: 'pl_deep_focus',
    title: 'Deep Focus',
    duration: '15 min',
    category: 'Deep Focus',
    imagePath: 'assets/images/sleep_story_night.jpg',
    isPremium: false,
    defaultAmbientSound: AmbientSound.binauralTheta,
    affirmations: [
      Affirmation(id: 'aff_df_1', quote: 'My mind is a laser, cutting through distractions and focusing on what matters.', category: 'Deep Focus'),
      Affirmation(id: 'aff_df_2', quote: 'I easily enter a state of flow where my productivity is effortless.', category: 'Deep Focus'),
      Affirmation(id: 'aff_df_3', quote: 'My attention is fully anchored in the present moment and my current task.', category: 'Deep Focus'),
      Affirmation(id: 'aff_df_4', quote: 'I release all scattered thoughts and embrace crystal-clear clarity.', category: 'Deep Focus'),
      Affirmation(id: 'aff_df_5', quote: 'I have the power to concentrate deeply for as long as I need.', category: 'Deep Focus'),
      Affirmation(id: 'aff_df_6', quote: 'My mental workspace is organized, calm, and primed for deep work.', category: 'Deep Focus'),
      Affirmation(id: 'aff_df_7', quote: 'I am immune to interruptions; my focus is unwavering and strong.', category: 'Deep Focus'),
      Affirmation(id: 'aff_df_8', quote: 'With every breath, my ability to concentrate grows stronger and sharper.', category: 'Deep Focus'),
    ],
  ),
  Playlist(
    id: 'pl_better_sleep',
    title: 'Better Sleep',
    duration: '20 min',
    category: 'Better Sleep',
    imagePath: 'assets/images/onboarding_moon_clouds.jpg',
    isPremium: false,
    defaultAmbientSound: AmbientSound.nightCrickets,
    affirmations: [
      Affirmation(id: 'aff_bs_1', quote: 'I release the events of the day and prepare my mind for deep, restorative rest.', category: 'Better Sleep'),
      Affirmation(id: 'aff_bs_2', quote: 'My body is heavy, relaxed, and sinking into the comfort of my bed.', category: 'Better Sleep'),
      Affirmation(id: 'aff_bs_3', quote: 'I give myself permission to sleep peacefully and wake up rejuvenated.', category: 'Better Sleep'),
      Affirmation(id: 'aff_bs_4', quote: 'Every breath out releases tension; every breath in brings tranquility.', category: 'Better Sleep'),
      Affirmation(id: 'aff_bs_5', quote: 'The night is a safe space for me to heal, recover, and dream.', category: 'Better Sleep'),
      Affirmation(id: 'aff_bs_6', quote: 'I let go of tomorrow’s worries and surrender to the stillness of tonight.', category: 'Better Sleep'),
      Affirmation(id: 'aff_bs_7', quote: 'My mind slows down, my heart rate settles, and I welcome sleep.', category: 'Better Sleep'),
      Affirmation(id: 'aff_bs_8', quote: 'I am enveloped in a cocoon of warmth, safety, and deep relaxation.', category: 'Better Sleep'),
    ],
  ),
  Playlist(
    id: 'pl_calm_mind',
    title: 'Calm Mind',
    duration: '10 min',
    category: 'Calm Mind',
    imagePath: 'assets/images/featured_meditation.jpg',
    isPremium: false,
    defaultAmbientSound: AmbientSound.ocean,
    affirmations: [
      Affirmation(id: 'aff_cm_1', quote: 'Peace begins within me, and I choose to cultivate it in every moment.', category: 'Calm Mind'),
      Affirmation(id: 'aff_cm_2', quote: 'I am the observer of my thoughts, not their captive.', category: 'Calm Mind'),
      Affirmation(id: 'aff_cm_3', quote: 'In the midst of chaos, I am the calm center of the storm.', category: 'Calm Mind'),
      Affirmation(id: 'aff_cm_4', quote: 'I breathe in serenity and exhale all stress and tension.', category: 'Calm Mind'),
      Affirmation(id: 'aff_cm_5', quote: 'My mind is like a still lake, reflecting only beauty and peace.', category: 'Calm Mind'),
      Affirmation(id: 'aff_cm_6', quote: 'I release the need to control everything and find comfort in simply being.', category: 'Calm Mind'),
      Affirmation(id: 'aff_cm_7', quote: 'Every passing moment brings me closer to profound emotional balance.', category: 'Calm Mind'),
      Affirmation(id: 'aff_cm_8', quote: 'I trust the flow of life and allow myself to rest in gentle tranquility.', category: 'Calm Mind'),
    ],
  ),

  // ==========================================
  // PREMIUM PLAYLISTS
  // ==========================================
  Playlist(
    id: 'pl_confidence',
    title: 'Confidence',
    duration: '12 min',
    category: 'Confidence',
    imagePath: 'assets/images/onboarding_archway_sun.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.solfeggio432,
    affirmations: [
      Affirmation(id: 'aff_cf_1', quote: 'I believe in my abilities and trust my intuition completely.', category: 'Confidence'),
      Affirmation(id: 'aff_cf_2', quote: 'I am worthy of respect, success, and all the good things life has to offer.', category: 'Confidence'),
      Affirmation(id: 'aff_cf_3', quote: 'My voice matters, and I speak my truth with unwavering courage.', category: 'Confidence'),
      Affirmation(id: 'aff_cf_4', quote: 'I step into my power and embrace the unique gifts I bring to the world.', category: 'Confidence'),
      Affirmation(id: 'aff_cf_5', quote: 'Challenges are simply opportunities for me to prove my resilience.', category: 'Confidence'),
      Affirmation(id: 'aff_cf_6', quote: 'I carry myself with grace, dignity, and quiet self-assurance.', category: 'Confidence'),
      Affirmation(id: 'aff_cf_7', quote: 'I am not defined by my past mistakes; I am defined by my potential.', category: 'Confidence'),
      Affirmation(id: 'aff_cf_8', quote: 'I stand tall, confident in who I am and who I am becoming.', category: 'Confidence'),
    ],
  ),
  Playlist(
    id: 'pl_self_love',
    title: 'Self Love',
    duration: '15 min',
    category: 'Self Love',
    imagePath: 'assets/images/onboarding_girl_profile.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.solfeggio852,
    affirmations: [
      Affirmation(id: 'aff_sl_1', quote: 'I accept myself unconditionally, embracing all my flaws and perfections.', category: 'Self Love'),
      Affirmation(id: 'aff_sl_2', quote: 'I treat myself with the same kindness and compassion I offer to others.', category: 'Self Love'),
      Affirmation(id: 'aff_sl_3', quote: 'My worth is inherent; it does not need to be earned or proven.', category: 'Self Love'),
      Affirmation(id: 'aff_sl_4', quote: 'I forgive myself for past mistakes and allow myself room to grow.', category: 'Self Love'),
      Affirmation(id: 'aff_sl_5', quote: 'I prioritize my well-being and set healthy boundaries with ease.', category: 'Self Love'),
      Affirmation(id: 'aff_sl_6', quote: 'I am beautiful, inside and out, exactly as I am right now.', category: 'Self Love'),
      Affirmation(id: 'aff_sl_7', quote: 'I nourish my body, mind, and soul with love and positive energy.', category: 'Self Love'),
      Affirmation(id: 'aff_sl_8', quote: 'Loving myself is the foundation for a joyful and fulfilled life.', category: 'Self Love'),
    ],
  ),
  Playlist(
    id: 'pl_anxiety_relief',
    title: 'Anxiety Relief',
    duration: '10 min',
    category: 'Anxiety Relief',
    imagePath: 'assets/images/onboarding_moon_clouds.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.rain,
    affirmations: [
      Affirmation(id: 'aff_ar_1', quote: 'I acknowledge my anxious thoughts and gently let them go.', category: 'Anxiety Relief'),
      Affirmation(id: 'aff_ar_2', quote: 'I am safe in this present moment, and all is well.', category: 'Anxiety Relief'),
      Affirmation(id: 'aff_ar_3', quote: 'I release the need to predict the future and trust the journey.', category: 'Anxiety Relief'),
      Affirmation(id: 'aff_ar_4', quote: 'With every breath, I inhale calm and exhale worry.', category: 'Anxiety Relief'),
      Affirmation(id: 'aff_ar_5', quote: 'This feeling is temporary, and it will pass like clouds in the sky.', category: 'Anxiety Relief'),
      Affirmation(id: 'aff_ar_6', quote: 'I have survived 100% of my bad days, and I am stronger than my fears.', category: 'Anxiety Relief'),
      Affirmation(id: 'aff_ar_7', quote: 'I choose faith over fear and peace over panic.', category: 'Anxiety Relief'),
      Affirmation(id: 'aff_ar_8', quote: 'My mind is clearing, my body is relaxing, and I am finding my anchor.', category: 'Anxiety Relief'),
    ],
  ),
  Playlist(
    id: 'pl_wealth_abundance',
    title: 'Wealth & Abundance',
    duration: '12 min',
    category: 'Wealth & Abundance',
    imagePath: 'assets/images/onboarding_archway_sun.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.solfeggio639,
    affirmations: [
      Affirmation(id: 'aff_wa_1', quote: 'I am open and receptive to all the wealth the universe has to offer.', category: 'Wealth & Abundance'),
      Affirmation(id: 'aff_wa_2', quote: 'Money flows to me easily, frequently, and in abundant quantities.', category: 'Wealth & Abundance'),
      Affirmation(id: 'aff_wa_3', quote: 'I am a magnet for financial prosperity and exciting new opportunities.', category: 'Wealth & Abundance'),
      Affirmation(id: 'aff_wa_4', quote: 'I release all limiting beliefs about money and embrace a mindset of abundance.', category: 'Wealth & Abundance'),
      Affirmation(id: 'aff_wa_5', quote: 'Every dollar I spend circulates and comes back to me multiplied.', category: 'Wealth & Abundance'),
      Affirmation(id: 'aff_wa_6', quote: 'I am grateful for the wealth I have and the wealth that is on its way.', category: 'Wealth & Abundance'),
      Affirmation(id: 'aff_wa_7', quote: 'My actions create constant wealth, prosperity, and financial freedom.', category: 'Wealth & Abundance'),
      Affirmation(id: 'aff_wa_8', quote: 'I deserve to be prosperous and use my wealth to create a better world.', category: 'Wealth & Abundance'),
    ],
  ),
  Playlist(
    id: 'pl_discipline',
    title: 'Discipline',
    duration: '10 min',
    category: 'Discipline',
    imagePath: 'assets/images/featured_meditation.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.binauralTheta,
    affirmations: [
      Affirmation(id: 'aff_ds_1', quote: 'I do what needs to be done, even when I don’t feel like it.', category: 'Discipline'),
      Affirmation(id: 'aff_ds_2', quote: 'My willpower is strong, and my daily habits align with my highest goals.', category: 'Discipline'),
      Affirmation(id: 'aff_ds_3', quote: 'I trade short-term gratification for long-term success and fulfillment.', category: 'Discipline'),
      Affirmation(id: 'aff_ds_4', quote: 'Consistency is my superpower, and I show up for myself every single day.', category: 'Discipline'),
      Affirmation(id: 'aff_ds_5', quote: 'I am the master of my impulses and the architect of my destiny.', category: 'Discipline'),
      Affirmation(id: 'aff_ds_6', quote: 'Every disciplined choice I make brings me closer to the life of my dreams.', category: 'Discipline'),
      Affirmation(id: 'aff_ds_7', quote: 'I embrace hard work because I know it builds character and strength.', category: 'Discipline'),
      Affirmation(id: 'aff_ds_8', quote: 'I commit to excellence and refuse to settle for mediocrity.', category: 'Discipline'),
    ],
  ),
  Playlist(
    id: 'pl_success',
    title: 'Success',
    duration: '15 min',
    category: 'Success',
    imagePath: 'assets/images/onboarding_archway_sun.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.windChimes,
    affirmations: [
      Affirmation(id: 'aff_sc_1', quote: 'I am meant for greatness, and success is my natural state of being.', category: 'Success'),
      Affirmation(id: 'aff_sc_2', quote: 'I attract success by being my authentic, capable, and driven self.', category: 'Success'),
      Affirmation(id: 'aff_sc_3', quote: 'Every setback is a setup for a greater comeback; I learn and I grow.', category: 'Success'),
      Affirmation(id: 'aff_sc_4', quote: 'I celebrate my achievements and use them as fuel for the journey ahead.', category: 'Success'),
      Affirmation(id: 'aff_sc_5', quote: 'I am surrounded by people who uplift me and support my vision.', category: 'Success'),
      Affirmation(id: 'aff_sc_6', quote: 'I create value in the world, and I am rewarded abundantly for it.', category: 'Success'),
      Affirmation(id: 'aff_sc_7', quote: 'My mind is a powerful engine of creativity, innovation, and triumph.', category: 'Success'),
      Affirmation(id: 'aff_sc_8', quote: 'I boldly step into the arena of life, ready to claim my victory.', category: 'Success'),
    ],
  ),
  Playlist(
    id: 'pl_motivation',
    title: 'Motivation',
    duration: '10 min',
    category: 'Motivation',
    imagePath: 'assets/images/featured_meditation.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.solfeggio528,
    affirmations: [
      Affirmation(id: 'aff_mo_1', quote: 'I am overflowing with drive, passion, and an unstoppable desire to win.', category: 'Motivation'),
      Affirmation(id: 'aff_mo_2', quote: 'The fire within me burns brighter than the fears around me.', category: 'Motivation'),
      Affirmation(id: 'aff_mo_3', quote: 'I don’t wait for inspiration; I take action and inspiration follows.', category: 'Motivation'),
      Affirmation(id: 'aff_mo_4', quote: 'I am the captain of my ship, steering purposefully toward my dreams.', category: 'Motivation'),
      Affirmation(id: 'aff_mo_5', quote: 'My energy is contagious, and I am ready to tackle any challenge head-on.', category: 'Motivation'),
      Affirmation(id: 'aff_mo_6', quote: 'I break through barriers and shatter limitations with fierce determination.', category: 'Motivation'),
      Affirmation(id: 'aff_mo_7', quote: 'Every step forward, no matter how small, is a victory worth celebrating.', category: 'Motivation'),
      Affirmation(id: 'aff_mo_8', quote: 'I am relentless in the pursuit of my goals and I will never give up.', category: 'Motivation'),
    ],
  ),
  Playlist(
    id: 'pl_productivity',
    title: 'Productivity',
    duration: '12 min',
    category: 'Productivity',
    imagePath: 'assets/images/sleep_story_night.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.forest,
    affirmations: [
      Affirmation(id: 'aff_pr_1', quote: 'I manage my time efficiently and accomplish my tasks with ease.', category: 'Productivity'),
      Affirmation(id: 'aff_pr_2', quote: 'I prioritize what matters most and eliminate trivial distractions.', category: 'Productivity'),
      Affirmation(id: 'aff_pr_3', quote: 'My workflow is seamless, and my output is of the highest quality.', category: 'Productivity'),
      Affirmation(id: 'aff_pr_4', quote: 'I take decisive action and move projects forward with momentum.', category: 'Productivity'),
      Affirmation(id: 'aff_pr_5', quote: 'I respect my time, and I ensure that every minute serves my purpose.', category: 'Productivity'),
      Affirmation(id: 'aff_pr_6', quote: 'I break large goals into actionable steps and execute them flawlessly.', category: 'Productivity'),
      Affirmation(id: 'aff_pr_7', quote: 'My environment is optimized for maximum efficiency and deep work.', category: 'Productivity'),
      Affirmation(id: 'aff_pr_8', quote: 'I end each day feeling accomplished, satisfied, and ready to rest.', category: 'Productivity'),
    ],
  ),
  Playlist(
    id: 'pl_relationships',
    title: 'Relationships',
    duration: '15 min',
    category: 'Relationships',
    imagePath: 'assets/images/onboarding_girl_profile.jpg',
    isPremium: true,
    defaultAmbientSound: AmbientSound.fireplace,
    affirmations: [
      Affirmation(id: 'aff_re_1', quote: 'I attract healthy, loving, and supportive relationships into my life.', category: 'Relationships'),
      Affirmation(id: 'aff_re_2', quote: 'I communicate openly, honestly, and with deep empathy for others.', category: 'Relationships'),
      Affirmation(id: 'aff_re_3', quote: 'I give and receive love freely, without fear or hesitation.', category: 'Relationships'),
      Affirmation(id: 'aff_re_4', quote: 'I am worthy of profound connection and deep emotional intimacy.', category: 'Relationships'),
      Affirmation(id: 'aff_re_5', quote: 'My relationships are built on a foundation of mutual trust and respect.', category: 'Relationships'),
      Affirmation(id: 'aff_re_6', quote: 'I hold space for the people I love to be their true, authentic selves.', category: 'Relationships'),
      Affirmation(id: 'aff_re_7', quote: 'I forgive easily, let go of resentment, and nurture peace in my bonds.', category: 'Relationships'),
      Affirmation(id: 'aff_re_8', quote: 'I am a beacon of love, and it reflects back to me from everyone I meet.', category: 'Relationships'),
    ],
  ),
];

List<Playlist> get freePlaylists => 
    allPlaylists.where((playlist) => !playlist.isPremium).toList();

List<Playlist> get premiumPlaylists => 
    allPlaylists.where((playlist) => playlist.isPremium).toList();

/// Aggregates all affirmations from both predefined playlists and the expanded scientific library
List<Affirmation> getAllGlobalAffirmations() {
  final Map<String, Affirmation> map = {};
  for (var aff in comprehensiveAffirmationLibrary) {
    map[aff.id] = aff;
  }
  for (var pl in allPlaylists) {
    for (var aff in pl.affirmations) {
      map.putIfAbsent(aff.id, () => aff);
    }
  }
  return map.values.toList();
}
