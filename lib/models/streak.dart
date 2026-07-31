class StreakData {
  int currentStreak;
  int longestStreak;
  int totalListeningDays;
  DateTime? lastActiveDate;
  List<String> unlockedBadges;

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalListeningDays = 0,
    this.lastActiveDate,
    this.unlockedBadges = const [],
  });

  double get weeklyProgress {
    int daysThisWeek = currentStreak % 7;
    if (daysThisWeek == 0 && currentStreak > 0) daysThisWeek = 7;
    return (currentStreak > 0) ? (daysThisWeek / 7.0) : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalListeningDays': totalListeningDays,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'unlockedBadges': unlockedBadges,
    };
  }

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalListeningDays: json['totalListeningDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null ? DateTime.parse(json['lastActiveDate'] as String) : null,
      unlockedBadges: (json['unlockedBadges'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  void incrementStreak(DateTime today) {
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (lastActiveDate == null) {
      currentStreak = 1;
      totalListeningDays = 1;
    } else {
      final lastDate = DateTime(lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);
      final difference = todayDate.difference(lastDate).inDays;
      
      if (difference == 1) {
        currentStreak++;
        totalListeningDays++;
      } else if (difference > 1) {
        currentStreak = 1;
        totalListeningDays++;
      } else {
        return; // Same day, no streak increment
      }
    }
    
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    
    lastActiveDate = today;
    checkAndUnlockBadges();
  }

  void resetStreak() {
    currentStreak = 0;
  }

  void checkAndUnlockBadges() {
    final milestones = [3, 7, 14, 30, 50, 100, 365];
    List<String> newBadges = List.from(unlockedBadges);
    
    for (int milestone in milestones) {
      String badgeName = '$milestone Days';
      if (currentStreak >= milestone && !newBadges.contains(badgeName)) {
        newBadges.add(badgeName);
      }
    }
    unlockedBadges = newBadges;
  }
}
