import 'package:flutter/foundation.dart';

import '../models/achievements.dart';
import '../models/course.dart';
import '../models/user_progress.dart';
import '../services/storage_service.dart';

/// Provides the [UserProgress] across the app and persists changes.
///
/// Centralises every mutation (XP gain, lesson completion, streak update,
/// reset/import/export) so the UI can simply call typed methods.
class ProgressProvider extends ChangeNotifier {
  final StorageService _storage;
  UserProgress _progress = UserProgress();
  bool _ready = false;

  /// Fired when an achievement is freshly unlocked, so UI can pop a banner.
  final ValueNotifier<Achievement?> newlyEarned = ValueNotifier(null);

  /// Fired when XP is gained, so UI can pop a +XP toast.
  final ValueNotifier<int?> xpJustGained = ValueNotifier(null);

  ProgressProvider({StorageService? storage})
      : _storage = storage ?? StorageService.instance;

  UserProgress get progress => _progress;
  bool get isReady => _ready;

  Future<void> load() async {
    _progress = await _storage.loadProgress();
    _ready = true;
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.saveProgress(_progress);
  }

  /// Mark a lesson complete and apply XP/accuracy/streak side-effects.
  ///
  /// [correctCount] / [totalCount] describe the quiz result; XP is awarded
  /// proportional to performance. A streak day is registered.
  Future<void> recordLessonResult({
    required Lesson lesson,
    required int correctCount,
    required int totalCount,
    int secondsSpent = 0,
  }) async {
    final accuracyPct =
        totalCount == 0 ? 0 : ((correctCount / totalCount) * 100).round();

    // XP scales with accuracy: base × (correct / total). Plus streak bonus.
    final base = lesson.xp;
    var earnedXp = (base * (correctCount / (totalCount == 0 ? 1 : totalCount)))
        .round();
    if (earnedXp < 1 && correctCount > 0) earnedXp = 1;

    // Streak bonus: +5 XP per streak day above 1 (capped).
    final streakBonus = (_progress.currentStreak - 1).clamp(0, 10) * 5;
    earnedXp += streakBonus;

    _progress.xp += earnedXp;
    _progress.completedLessonIds.add(lesson.id);
    _progress.lessonAccuracy[lesson.id] = accuracyPct;
    _progress.lessonStars[lesson.id] = _starsFor(accuracyPct);
    _progress.totalQuestionsAnswered += totalCount;
    _progress.totalQuestionsCorrect += correctCount;
    _progress.totalSecondsStudied += secondsSpent;

    _registerActivityToday();
    _checkAchievements();
    await _save();

    xpJustGained.value = earnedXp;
    notifyListeners();
  }

  int _starsFor(int accuracyPct) {
    if (accuracyPct >= 100) return 3;
    if (accuracyPct >= 80) return 2;
    if (accuracyPct >= 60) return 1;
    return 0;
  }

  /// Update the streak counter. Call this any time the user is active.
  ///
  /// Rules:
  ///   - same day:    streak unchanged
  ///   - next day:    streak += 1
  ///   - skipped day: streak resets to 1
  ///   - first ever:  streak = 1
  void _registerActivityToday() {
    final today = _todayString();
    final last = _progress.lastActiveDate;
    if (last == today) return;
    if (last == null) {
      _progress.currentStreak = 1;
    } else {
      final lastDate = DateTime.tryParse(last);
      final now = DateTime.now();
      if (lastDate != null) {
        final diff = DateTime(now.year, now.month, now.day)
            .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
            .inDays;
        if (diff == 1) {
          _progress.currentStreak += 1;
        } else if (diff > 1) {
          _progress.currentStreak = 1;
        }
      } else {
        _progress.currentStreak = 1;
      }
    }
    if (_progress.currentStreak > _progress.longestStreak) {
      _progress.longestStreak = _progress.currentStreak;
    }
    _progress.lastActiveDate = today;
  }

  /// Call when the user merely opens the app, without finishing a lesson.
  Future<void> touchActivity() async {
    final before = _progress.lastActiveDate;
    _registerActivityToday();
    if (before != _progress.lastActiveDate) {
      await _save();
      notifyListeners();
    }
  }

  void _checkAchievements() {
    for (final a in Achievements.all) {
      if (!_progress.earnedAchievementIds.contains(a.id) &&
          a.isEarned(_progress)) {
        _progress.earnedAchievementIds.add(a.id);
        newlyEarned.value = a;
      }
    }
  }

  Future<void> resetAll() async {
    _progress = UserProgress();
    await _storage.resetProgress();
    notifyListeners();
  }

  /// Returns the current progress as a JSON string (for export).
  String exportJson() => _progress.toJsonString();

  /// Imports progress from a JSON string. Throws on invalid input.
  Future<void> importJson(String s) async {
    _progress = UserProgress.fromJsonString(s);
    await _save();
    notifyListeners();
  }

  /// Returns the user's lifetime accuracy on a 0..1 scale, NaN-safe.
  double get accuracyFraction =>
      _progress.totalQuestionsAnswered == 0
          ? 0
          : _progress.totalQuestionsCorrect /
              _progress.totalQuestionsAnswered;

  bool isCompleted(Lesson l) => _progress.completedLessonIds.contains(l.id);

  /// Determines whether [lesson] is unlocked. The first lesson of the course
  /// is always unlocked; subsequent lessons unlock once the previous one is
  /// completed (a Duolingo-style chain).
  bool isUnlocked(Course course, Lesson lesson) {
    final all = course.allLessons;
    final idx = all.indexWhere((l) => l.id == lesson.id);
    if (idx <= 0) return true;
    final prev = all[idx - 1];
    return _progress.completedLessonIds.contains(prev.id);
  }

  /// Returns the next lesson the user should tackle (first unlocked &
  /// uncompleted), or null if everything is done.
  Lesson? nextLesson(Course course) {
    final all = course.allLessons;
    for (final l in all) {
      if (!_progress.completedLessonIds.contains(l.id) &&
          isUnlocked(course, l)) {
        return l;
      }
    }
    return null;
  }

  String _todayString() {
    final n = DateTime.now();
    String pad(int x) => x.toString().padLeft(2, '0');
    return '${n.year}-${pad(n.month)}-${pad(n.day)}';
  }

  void clearXpToast() => xpJustGained.value = null;
  void clearAchievementToast() => newlyEarned.value = null;
}
