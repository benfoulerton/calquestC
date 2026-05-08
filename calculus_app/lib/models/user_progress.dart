import 'dart:convert';

/// Snapshot of a user's progress, persisted as JSON in shared_preferences.
///
/// The level system: every 100 XP advances the user by one level.
/// Accuracy tracks total questions answered vs total correct, lifetime.
class UserProgress {
  int xp;
  Set<String> completedLessonIds;
  Map<String, int> lessonStars;      // lessonId -> 0..3 stars (out of 5 questions, scaled)
  Map<String, int> lessonAccuracy;   // lessonId -> last accuracy %
  int totalQuestionsAnswered;
  int totalQuestionsCorrect;
  int currentStreak;
  int longestStreak;
  String? lastActiveDate;            // yyyy-MM-dd
  Set<String> earnedAchievementIds;
  int totalSecondsStudied;

  UserProgress({
    this.xp = 0,
    Set<String>? completedLessonIds,
    Map<String, int>? lessonStars,
    Map<String, int>? lessonAccuracy,
    this.totalQuestionsAnswered = 0,
    this.totalQuestionsCorrect = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    Set<String>? earnedAchievementIds,
    this.totalSecondsStudied = 0,
  })  : completedLessonIds = completedLessonIds ?? <String>{},
        lessonStars = lessonStars ?? <String, int>{},
        lessonAccuracy = lessonAccuracy ?? <String, int>{},
        earnedAchievementIds = earnedAchievementIds ?? <String>{};

  /// Level: every 100 XP = +1 level. Level 1 starts at 0 XP.
  int get level => 1 + (xp ~/ 100);

  /// XP earned within the current level (0..99).
  int get xpInLevel => xp % 100;

  /// XP needed to reach the next level (100 minus xpInLevel).
  int get xpToNextLevel => 100 - xpInLevel;

  /// Lifetime accuracy as a percentage 0..100.
  double get lifetimeAccuracy {
    if (totalQuestionsAnswered == 0) return 0;
    return (totalQuestionsCorrect / totalQuestionsAnswered) * 100;
  }

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'completedLessonIds': completedLessonIds.toList(),
        'lessonStars': lessonStars,
        'lessonAccuracy': lessonAccuracy,
        'totalQuestionsAnswered': totalQuestionsAnswered,
        'totalQuestionsCorrect': totalQuestionsCorrect,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': lastActiveDate,
        'earnedAchievementIds': earnedAchievementIds.toList(),
        'totalSecondsStudied': totalSecondsStudied,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      completedLessonIds: ((json['completedLessonIds'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
      lessonStars: ((json['lessonStars'] as Map?) ?? const {})
          .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      lessonAccuracy: ((json['lessonAccuracy'] as Map?) ?? const {})
          .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      totalQuestionsAnswered:
          (json['totalQuestionsAnswered'] as num?)?.toInt() ?? 0,
      totalQuestionsCorrect:
          (json['totalQuestionsCorrect'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['lastActiveDate']?.toString(),
      earnedAchievementIds:
          ((json['earnedAchievementIds'] as List?) ?? const [])
              .map((e) => e.toString())
              .toSet(),
      totalSecondsStudied: (json['totalSecondsStudied'] as num?)?.toInt() ?? 0,
    );
  }

  factory UserProgress.fromJsonString(String s) {
    return UserProgress.fromJson(jsonDecode(s) as Map<String, dynamic>);
  }
}

/// Definition of an achievement (badge). Static catalogue.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool Function(UserProgress p) isEarned;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isEarned,
  });
}
