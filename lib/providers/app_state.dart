// lib/providers/app_state.dart
//
// One ChangeNotifier holds everything: user progress, settings, review queue,
// and theme choices. Centralised because nearly every screen reads/writes
// some of it. Persists via StorageService.

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/micro_screen.dart';
import '../models/user_progress.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  AppState({StorageService? storage})
      : _storage = storage ?? StorageService.instance;

  final StorageService _storage;
  UserProgress _progress = UserProgress();
  bool _ready = false;

  /// Transient toast notifiers — UI overlays watch these.
  final ValueNotifier<int?> xpJustGained = ValueNotifier(null);
  final ValueNotifier<String?> achievementJustEarned = ValueNotifier(null);

  UserProgress get progress => _progress;
  bool get isReady => _ready;

  // ---- Lifecycle ----

  Future<void> load() async {
    _progress = await _storage.loadProgress();
    _ready = true;
    notifyListeners();
  }

  Future<void> _save() async => _storage.saveProgress(_progress);

  // ---- Theme & settings ----

  ThemePreset get activeTheme => ThemePresets.byId(_progress.activeThemeId);

  Future<void> setActiveTheme(String id) async {
    if (!_progress.unlockedThemeIds.contains(id)) {
      _progress.unlockedThemeIds.add(id);
    }
    _progress.activeThemeId = id;
    await _save();
    notifyListeners();
  }

  Future<void> unlockTheme(String id) async {
    if (_progress.unlockedThemeIds.add(id)) {
      await _save();
      notifyListeners();
    }
  }

  Future<void> setUseDynamicColor(bool v) async {
    _progress.useDynamicColor = v;
    await _save();
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    _progress.darkMode = v;
    await _save();
    notifyListeners();
  }

  Future<void> setReduceMotion(bool v) async {
    _progress.reduceMotion = v;
    await _save();
    notifyListeners();
  }

  Future<void> setSoundOn(bool v) async {
    _progress.soundOn = v;
    await _save();
    notifyListeners();
  }

  Future<void> setHapticsOn(bool v) async {
    _progress.hapticsOn = v;
    await _save();
    notifyListeners();
  }

  Future<void> setDailyGoal(int minutes) async {
    _progress.dailyGoalMinutes = minutes;
    await _save();
    notifyListeners();
  }

  // ---- Activity / streak ----

  /// Touched whenever the user opens the app or completes a screen. Updates
  /// the streak counter according to calendar day comparisons.
  Future<void> touchActivity() async {
    final today = _todayKey();
    final last = _progress.lastActiveDay;
    bool changed = false;
    if (last == null) {
      _progress.currentStreak = 1;
      changed = true;
    } else if (last != today) {
      final lastDate = DateTime.tryParse(last);
      if (lastDate != null) {
        final diff = _dayDiff(lastDate, DateTime.now());
        if (diff == 1) {
          _progress.currentStreak += 1;
          changed = true;
        } else if (diff > 1) {
          // Use a streak freeze if available, else reset.
          if (_progress.streakFreezes > 0) {
            _progress.streakFreezes -= 1;
          } else {
            _progress.currentStreak = 1;
          }
          changed = true;
        }
      }
    }
    if (last != today) {
      _progress.lastActiveDay = today;
      changed = true;
    }
    if (_progress.currentStreak > _progress.longestStreak) {
      _progress.longestStreak = _progress.currentStreak;
    }
    if (changed) {
      await _save();
      notifyListeners();
    }
  }

  // ---- Lesson completion ----

  /// Called by the lesson runner when a lesson finishes.
  Future<void> recordLessonResult({
    required Lesson lesson,
    required int correct,
    required int total,
    required Map<String, bool> itemResults,
  }) async {
    final accuracy = total == 0 ? 0.0 : correct / total;
    final stars = accuracy >= 1.0
        ? 3
        : accuracy >= 0.85
            ? 2
            : accuracy >= 0.6
                ? 1
                : 0;

    var earnedXp = lesson.xpReward;
    if (stars == 3) earnedXp += 5; // perfect bonus
    if (_progress.currentStreak >= 3) earnedXp += 3; // streak bonus

    _progress.xp += earnedXp;
    _progress.completedLessonIds.add(lesson.id);
    final prevStars = _progress.lessonStars[lesson.id] ?? 0;
    if (stars > prevStars) _progress.lessonStars[lesson.id] = stars;

    _progress.totalCorrect += correct;
    _progress.totalAnswered += total;

    // Update review items (FSRS-lite).
    itemResults.forEach((itemId, wasCorrect) {
      final item = _progress.reviewItems[itemId] ??
          ReviewItem(itemId: itemId);
      if (wasCorrect) {
        item.recordSuccess();
      } else {
        item.recordFailure();
      }
      _progress.reviewItems[itemId] = item;
    });

    await touchActivity(); // also handles save
    xpJustGained.value = earnedXp;
    await _save();
    notifyListeners();

    // Achievement checks.
    _checkAchievements();
  }

  void _checkAchievements() {
    final n = _progress.completedLessonIds.length;
    if (n == 1) achievementJustEarned.value = 'First Steps';
    if (n == 5) achievementJustEarned.value = 'Five Down';
    if (n == 10) achievementJustEarned.value = 'Getting Serious';
    if (_progress.currentStreak == 3) achievementJustEarned.value = 'On a Roll';
    if (_progress.currentStreak == 7) achievementJustEarned.value = 'Week Warrior';
    if (_progress.xp >= 500 && _progress.xp - (_progress.xp % 100) == 500) {
      achievementJustEarned.value = '500 XP!';
    }
  }

  void clearXpToast() => xpJustGained.value = null;
  void clearAchievementToast() => achievementJustEarned.value = null;

  // ---- Review queue ----

  /// All review items currently due, oldest first.
  List<ReviewItem> dueReviewItems() => _progress.dueReviews;

  // ---- Reset ----

  Future<void> resetAll() async {
    _progress = UserProgress();
    await _storage.reset();
    notifyListeners();
  }

  // ---- Helpers ----

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  int _dayDiff(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }
}
