import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/daily_quotes.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/streak_badge.dart';
import '../widgets/xp_progress_bar.dart';
import 'loading_screen.dart';

/// The home tab — at-a-glance summary plus the main "Continue" action.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    final progressProv = context.watch<ProgressProvider>();

    if (courseProv.isLoading || courseProv.course == null) {
      return const LoadingScreen();
    }
    if (courseProv.error != null) {
      return _ErrorState(error: courseProv.error!);
    }
    final course = courseProv.course!;
    final progress = progressProv.progress;
    final next = progressProv.nextLesson(course);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Header: greeting + streak.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Calculus Quest',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              StreakBadge(streak: progress.currentStreak, large: true),
            ],
          ),
          const SizedBox(height: 22),

          // XP / level card.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  XpProgressBar(
                    xpInLevel: progress.xpInLevel,
                    level: progress.level,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniStat(
                          label: 'Total XP', value: '${progress.xp}'),
                      _MiniStat(
                          label: 'Lessons',
                          value:
                              '${progress.completedLessonIds.length}/${course.totalLessons}'),
                      _MiniStat(
                        label: 'Accuracy',
                        value:
                            '${progress.lifetimeAccuracy.toStringAsFixed(0)}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Continue button.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    next == null
                        ? 'You finished every lesson!'
                        : 'Up next',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    next?.title ?? 'Time to celebrate.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (next != null)
                    PrimaryButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Continue learning',
                      onPressed: () => context.push('/lesson/${Uri.encodeComponent(next.id)}'),
                    )
                  else
                    PrimaryButton(
                      icon: Icons.refresh_rounded,
                      label: 'Practise again',
                      onPressed: () => context.go('/path'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions.
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  color: AppColors.primary,
                  onTap: () => context.push('/search'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.psychology_rounded,
                  label: 'Smart review',
                  color: AppColors.accent,
                  onTap: () => context.push('/review'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.emoji_events_rounded,
                  label: 'Badges',
                  color: AppColors.warning,
                  onTap: () => context.push('/achievements'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daily quote.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_quote_rounded,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 6),
                      Text('Daily inspiration',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DailyQuotes.forToday(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recent lessons.
          _RecentLessons(course: course),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
        const SizedBox(height: 2),
        Text(label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: AppColors.textFaint,
                )),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentLessons extends StatelessWidget {
  final Course course;
  const _RecentLessons({required this.course});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>().progress;
    // Pick the most recent 4 completed lessons (in course order).
    final completedInOrder = course.allLessons
        .where((l) => progress.completedLessonIds.contains(l.id))
        .toList();
    final recent = completedInOrder.length <= 4
        ? completedInOrder.reversed.toList()
        : completedInOrder.sublist(completedInOrder.length - 4).reversed.toList();

    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Recently completed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < recent.length; i++) ...[
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: AppColors.success),
                  ),
                  title: Text(recent[i].title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(
                    '${progress.lessonAccuracy[recent[i].id] ?? 0}% accuracy · +${recent[i].xp} XP',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(
                      '/lesson/${Uri.encodeComponent(recent[i].id)}'),
                ),
                if (i != recent.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text('Could not load the course',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('$error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
