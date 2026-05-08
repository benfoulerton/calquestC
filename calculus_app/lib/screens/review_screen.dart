import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

/// "Smart review" mode: surfaces the lessons where the user scored lowest
/// so they can re-attempt the quiz. Lessons with accuracy < 80% appear,
/// sorted ascending. Empty state encourages more practice.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    final progressProv = context.watch<ProgressProvider>();

    if (courseProv.isLoading || courseProv.course == null) {
      return const LoadingScreen();
    }
    final course = courseProv.course!;
    final p = progressProv.progress;

    // Build the candidate list: completed lessons whose accuracy is below 80%.
    final weakLessons = <_WeakLesson>[];
    for (final l in course.allLessons) {
      if (!p.completedLessonIds.contains(l.id)) continue;
      final acc = p.lessonAccuracy[l.id] ?? 0;
      if (acc < 80) {
        weakLessons.add(_WeakLesson(l, acc));
      }
    }
    weakLessons.sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return Scaffold(
      appBar: AppBar(title: const Text('Smart review')),
      body: SafeArea(
        child: weakLessons.isEmpty
            ? _EmptyState(
                hasCompleted: p.completedLessonIds.isNotEmpty,
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.psychology_rounded,
                                color: AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Targeted practice',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Re-quizzing your lowest-scoring lessons builds the strongest gains.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('${weakLessons.length} lesson${weakLessons.length == 1 ? '' : 's'} to review',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  for (var i = 0; i < weakLessons.length; i++) ...[
                    _WeakCard(weak: weakLessons[i]),
                    if (i != weakLessons.length - 1)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
      ),
    );
  }
}

class _WeakLesson {
  final Lesson lesson;
  final int accuracy;
  _WeakLesson(this.lesson, this.accuracy);
}

class _WeakCard extends StatelessWidget {
  final _WeakLesson weak;
  const _WeakCard({required this.weak});

  @override
  Widget build(BuildContext context) {
    final color = weak.accuracy < 60
        ? AppColors.error
        : AppColors.warning;
    return Card(
      child: InkWell(
        onTap: () =>
            context.push('/quiz/${Uri.encodeComponent(weak.lesson.id)}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${weak.accuracy}%',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weak.lesson.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to retake the quiz',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppColors.textFaint,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasCompleted;
  const _EmptyState({required this.hasCompleted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              hasCompleted
                  ? 'Nothing to review!'
                  : 'No completed lessons yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              hasCompleted
                  ? 'Every completed lesson is at 80% or above. Solid work — keep going.'
                  : 'Complete a few lessons first; this screen will then surface the ones you need to revisit.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              icon: const Icon(Icons.timeline_rounded),
              onPressed: () => context.go('/path'),
              label: const Text('Open course path'),
            ),
          ],
        ),
      ),
    );
  }
}
