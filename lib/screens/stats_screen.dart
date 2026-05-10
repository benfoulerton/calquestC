// lib/screens/stats_screen.dart
//
// Personal stats overview. Per-unit completion bars are the most
// motivating element — visualise progress as a filled track per unit.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/curriculum.dart';
import '../models/lesson.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // Top row: XP + level.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radLarge),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded,
                    color: scheme.onPrimaryContainer, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total XP',
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text('${app.progress.xp}',
                          style: Theme.of(context).textTheme.displayMedium),
                      Text('Level ${app.progress.level}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                  )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stat grid.
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Current streak',
                  value: '${app.progress.currentStreak} days',
                  color: palette.streak,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Best streak',
                  value: '${app.progress.longestStreak} days',
                  color: palette.streak,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.target_rounded,
                  label: 'Accuracy',
                  value: '${app.progress.accuracyPct.round()}%',
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.school_rounded,
                  label: 'Lessons done',
                  value: '${app.progress.completedLessonIds.length}',
                  color: scheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Progress by unit',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final unit in Curriculum.units) _UnitProgressBar(
            unit: unit,
            completedIds: app.progress.completedLessonIds,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
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
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _UnitProgressBar extends StatelessWidget {
  const _UnitProgressBar({required this.unit, required this.completedIds});
  final Unit unit;
  final Set<String> completedIds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lessons = unit.lessons;
    final done = lessons.where((l) => completedIds.contains(l.id)).length;
    final total = lessons.length;
    final pct = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppTheme.radMedium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(unit.icon,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(unit.title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text('$done / $total',
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
