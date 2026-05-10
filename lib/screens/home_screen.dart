// lib/screens/home_screen.dart
//
// First-tab dashboard. The most important element is the "Continue
// Learning" button — single tap into the next lesson, no menus, no
// chooser. ADHD task-initiation friction must be sub-10s.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/curriculum.dart';
import '../models/lesson.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);
    final app = context.watch<AppState>();
    final all = Curriculum.allLessons;
    Lesson? next;
    for (final l in all) {
      if (!app.progress.completedLessonIds.contains(l.id)) {
        next = l;
        break;
      }
    }
    final completedCount = app.progress.completedLessonIds.length;
    final totalCount = Curriculum.totalLessons;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        next == null
                            ? 'You\'ve done it all 🎉'
                            : next.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StreakBadge(streak: app.progress.currentStreak,
                    streakColor: palette.streak),
              ],
            ),
            const SizedBox(height: 20),
            // Continue / Start FAB-style.
            if (next != null)
              _ContinueCard(lesson: next).animate().fadeIn(duration: 280.ms),
            const SizedBox(height: 20),
            _LevelBar(
                xp: app.progress.xp,
                level: app.progress.level,
                xpInLevel: app.progress.xpInLevel),
            const SizedBox(height: 20),
            // Quick stats.
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.school_rounded,
                    label: 'Lessons done',
                    value: '$completedCount / $totalCount',
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.track_changes_rounded,
                    label: 'Accuracy',
                    value: '${app.progress.accuracyPct.round()}%',
                    color: scheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.bolt_rounded,
                    label: 'Total XP',
                    value: '${app.progress.xp}',
                    color: palette.streak,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.replay_rounded,
                    label: 'Due reviews',
                    value: '${app.dueReviewItems().length}',
                    color: scheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Daily quests strip.
            _DailyQuests(app: app),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak, required this.streakColor});
  final int streak;
  final Color streakColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: streakColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              color: streakColor, size: 22),
          const SizedBox(width: 4),
          Text('$streak',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: streakColor, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.go('/lesson/${lesson.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(AppTheme.radLarge),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.onPrimary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(lesson.icon,
                    style: TextStyle(
                        fontSize: 26,
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Continue learning',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: scheme.onPrimary.withOpacity(0.8))),
                  const SizedBox(height: 2),
                  Text(lesson.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(lesson.subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onPrimary.withOpacity(0.85))),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded,
                color: scheme.onPrimary, size: 32),
          ],
        ),
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  const _LevelBar(
      {required this.xp, required this.level, required this.xpInLevel});
  final int xp, level, xpInLevel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = xpInLevel / 100;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                child: Text('$level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level $level',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${100 - xpInLevel} XP to next level',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Text('$xp XP',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _DailyQuests extends StatelessWidget {
  const _DailyQuests({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    // Quests are derived from progress — lightweight, no separate state.
    final scheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final completedToday = app.progress.lastActiveDay ==
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final quests = [
      _Quest(
        title: 'Finish 1 lesson',
        done: completedToday,
        icon: Icons.school_rounded,
      ),
      _Quest(
        title: 'Earn ${app.progress.dailyGoalMinutes * 4} XP',
        done: false, // simplified — real impl would count today's XP
        icon: Icons.bolt_rounded,
      ),
      _Quest(
        title: 'Hit ${app.progress.dailyGoalMinutes} min',
        done: false,
        icon: Icons.timer_outlined,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              Text("Today's quests",
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          for (final q in quests) ...[
            _QuestRow(quest: q),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _Quest {
  const _Quest({required this.title, required this.done, required this.icon});
  final String title;
  final bool done;
  final IconData icon;
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({required this.quest});
  final _Quest quest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                quest.done ? palette.successContainer : scheme.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          child: Icon(
            quest.done ? Icons.check_rounded : quest.icon,
            color: quest.done ? palette.success : scheme.onSurfaceVariant,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            quest.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  decoration:
                      quest.done ? TextDecoration.lineThrough : null,
                  color: quest.done
                      ? scheme.onSurfaceVariant
                      : scheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
