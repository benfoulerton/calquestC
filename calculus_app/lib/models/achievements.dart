import 'user_progress.dart';

/// Static catalogue of achievements. Each one is checked against current
/// [UserProgress] to decide whether it has been earned.
class Achievements {
  static final List<Achievement> all = <Achievement>[
    Achievement(
      id: 'first_lesson',
      title: 'First Steps',
      description: 'Complete your first lesson.',
      emoji: '🌱',
      isEarned: (p) => p.completedLessonIds.isNotEmpty,
    ),
    Achievement(
      id: 'ten_lessons',
      title: 'Getting Serious',
      description: 'Complete 10 lessons.',
      emoji: '📚',
      isEarned: (p) => p.completedLessonIds.length >= 10,
    ),
    Achievement(
      id: 'fifty_lessons',
      title: 'Halfway Hero',
      description: 'Complete 50 lessons.',
      emoji: '🏔️',
      isEarned: (p) => p.completedLessonIds.length >= 50,
    ),
    Achievement(
      id: 'all_lessons',
      title: 'Calculus Master',
      description: 'Complete every lesson in the course.',
      emoji: '👑',
      isEarned: (p) => p.completedLessonIds.length >= 116,
    ),
    Achievement(
      id: 'streak_3',
      title: 'On a Roll',
      description: 'Maintain a 3-day streak.',
      emoji: '🔥',
      isEarned: (p) => p.currentStreak >= 3 || p.longestStreak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak.',
      emoji: '⚡',
      isEarned: (p) => p.currentStreak >= 7 || p.longestStreak >= 7,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Iron Discipline',
      description: 'Maintain a 30-day streak.',
      emoji: '💎',
      isEarned: (p) => p.currentStreak >= 30 || p.longestStreak >= 30,
    ),
    Achievement(
      id: 'xp_500',
      title: 'XP Collector',
      description: 'Earn 500 XP total.',
      emoji: '⭐',
      isEarned: (p) => p.xp >= 500,
    ),
    Achievement(
      id: 'xp_1000',
      title: 'Quadrillion XP',
      description: 'Earn 1000 XP total.',
      emoji: '🌟',
      isEarned: (p) => p.xp >= 1000,
    ),
    Achievement(
      id: 'accuracy_90',
      title: 'Sharp Mind',
      description: 'Reach 90% lifetime accuracy (after 50+ questions).',
      emoji: '🎯',
      isEarned: (p) =>
          p.totalQuestionsAnswered >= 50 && p.lifetimeAccuracy >= 90,
    ),
    Achievement(
      id: 'integration_unlocked',
      title: 'Integration Initiate',
      description: 'Begin Chapter 5: Integrals.',
      emoji: '∫',
      isEarned: (p) => p.completedLessonIds
          .any((id) => id.startsWith('5.')),
    ),
    Achievement(
      id: 'series_unlocked',
      title: 'Series Sage',
      description: 'Complete a lesson from Chapter 11 (Series).',
      emoji: 'Σ',
      isEarned: (p) => p.completedLessonIds
          .any((id) => id.startsWith('11.')),
    ),
    Achievement(
      id: 'multivar_unlocked',
      title: 'Into the Third Dimension',
      description: 'Complete a lesson from Chapter 12 or later.',
      emoji: '🧊',
      isEarned: (p) => p.completedLessonIds.any((id) {
        final m = RegExp(r'^(\d+)\.').firstMatch(id);
        if (m == null) return false;
        return int.parse(m.group(1)!) >= 12;
      }),
    ),
  ];
}
