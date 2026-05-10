// lib/models/user_progress.dart
//
// Persistent user state. Serialised as JSON to shared_preferences.
//
// We use an FSRS-LITE scheduler: each item tracks stability (in days) and
// the next due date. On a correct review, stability roughly doubles; on an
// incorrect review, it resets to a small value. Far simpler than full FSRS
// but captures the spaced-repetition behaviour the brief calls for.

import 'dart:convert';

class ReviewItem {
  ReviewItem({
    required this.itemId,
    this.stabilityDays = 1.0,
    this.lapses = 0,
    DateTime? lastReview,
    DateTime? dueAt,
  })  : lastReview = lastReview ?? DateTime.now(),
        dueAt = dueAt ?? DateTime.now().add(const Duration(days: 1));

  String itemId;
  double stabilityDays;
  int lapses;
  DateTime lastReview;
  DateTime dueAt;

  /// Update on a correct response. Stability ~doubles, capped at 365.
  void recordSuccess() {
    stabilityDays = (stabilityDays * 2.2).clamp(1.0, 365.0);
    lastReview = DateTime.now();
    dueAt = lastReview.add(Duration(hours: (stabilityDays * 24).round()));
  }

  /// Update on an incorrect response. Stability resets, lapses increment.
  void recordFailure() {
    stabilityDays = (stabilityDays * 0.4).clamp(0.5, 365.0);
    lapses += 1;
    lastReview = DateTime.now();
    // Reschedule for ~6 hours later, plus a bit per lapse.
    dueAt = lastReview.add(Duration(hours: 6 + lapses));
  }

  /// True if this item is due for review now.
  bool get isDue => DateTime.now().isAfter(dueAt);

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'stabilityDays': stabilityDays,
        'lapses': lapses,
        'lastReview': lastReview.toIso8601String(),
        'dueAt': dueAt.toIso8601String(),
      };

  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(
        itemId: j['itemId'] as String,
        stabilityDays: (j['stabilityDays'] as num?)?.toDouble() ?? 1.0,
        lapses: (j['lapses'] as num?)?.toInt() ?? 0,
        lastReview: DateTime.tryParse(j['lastReview'] as String? ?? '') ??
            DateTime.now(),
        dueAt: DateTime.tryParse(j['dueAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class UserProgress {
  UserProgress({
    this.xp = 0,
    Set<String>? completedLessonIds,
    Map<String, int>? lessonStars,
    this.totalCorrect = 0,
    this.totalAnswered = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDay,
    this.streakFreezes = 2,
    Map<String, ReviewItem>? reviewItems,
    this.dailyGoalMinutes = 5,
    Set<String>? unlockedThemeIds,
    this.activeThemeId = 'ocean',
    this.useDynamicColor = false,
    this.darkMode = false,
    this.reduceMotion = false,
    this.soundOn = true,
    this.hapticsOn = true,
  })  : completedLessonIds = completedLessonIds ?? <String>{},
        lessonStars = lessonStars ?? <String, int>{},
        reviewItems = reviewItems ?? <String, ReviewItem>{},
        unlockedThemeIds = unlockedThemeIds ?? {'ocean', 'forest', 'mono'};

  int xp;
  Set<String> completedLessonIds;
  Map<String, int> lessonStars; // 0..3
  int totalCorrect;
  int totalAnswered;
  int currentStreak;
  int longestStreak;
  String? lastActiveDay; // yyyy-MM-dd
  int streakFreezes;
  Map<String, ReviewItem> reviewItems;
  int dailyGoalMinutes;
  Set<String> unlockedThemeIds;
  String activeThemeId;
  bool useDynamicColor;
  bool darkMode;
  bool reduceMotion;
  bool soundOn;
  bool hapticsOn;

  int get level => 1 + (xp ~/ 100);
  int get xpInLevel => xp % 100;

  double get accuracyPct =>
      totalAnswered == 0 ? 0 : (totalCorrect / totalAnswered) * 100;

  /// All review items currently due.
  List<ReviewItem> get dueReviews =>
      reviewItems.values.where((r) => r.isDue).toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'completedLessonIds': completedLessonIds.toList(),
        'lessonStars': lessonStars,
        'totalCorrect': totalCorrect,
        'totalAnswered': totalAnswered,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDay': lastActiveDay,
        'streakFreezes': streakFreezes,
        'reviewItems': reviewItems.map((k, v) => MapEntry(k, v.toJson())),
        'dailyGoalMinutes': dailyGoalMinutes,
        'unlockedThemeIds': unlockedThemeIds.toList(),
        'activeThemeId': activeThemeId,
        'useDynamicColor': useDynamicColor,
        'darkMode': darkMode,
        'reduceMotion': reduceMotion,
        'soundOn': soundOn,
        'hapticsOn': hapticsOn,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserProgress.fromJson(Map<String, dynamic> j) => UserProgress(
        xp: (j['xp'] as num?)?.toInt() ?? 0,
        completedLessonIds: ((j['completedLessonIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
        lessonStars: ((j['lessonStars'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
        totalCorrect: (j['totalCorrect'] as num?)?.toInt() ?? 0,
        totalAnswered: (j['totalAnswered'] as num?)?.toInt() ?? 0,
        currentStreak: (j['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (j['longestStreak'] as num?)?.toInt() ?? 0,
        lastActiveDay: j['lastActiveDay'] as String?,
        streakFreezes: (j['streakFreezes'] as num?)?.toInt() ?? 2,
        reviewItems: ((j['reviewItems'] as Map?) ?? const {}).map(
          (k, v) => MapEntry(
            k.toString(),
            ReviewItem.fromJson(Map<String, dynamic>.from(v as Map)),
          ),
        ),
        dailyGoalMinutes: (j['dailyGoalMinutes'] as num?)?.toInt() ?? 5,
        unlockedThemeIds: ((j['unlockedThemeIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
        activeThemeId: j['activeThemeId']?.toString() ?? 'ocean',
        useDynamicColor: j['useDynamicColor'] as bool? ?? false,
        darkMode: j['darkMode'] as bool? ?? false,
        reduceMotion: j['reduceMotion'] as bool? ?? false,
        soundOn: j['soundOn'] as bool? ?? true,
        hapticsOn: j['hapticsOn'] as bool? ?? true,
      );

  factory UserProgress.fromJsonString(String s) =>
      UserProgress.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
