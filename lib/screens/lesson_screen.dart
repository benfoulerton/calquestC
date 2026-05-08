import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/content_cards.dart';
import '../widgets/primary_button.dart';
import 'loading_screen.dart';

/// Renders the content of a single lesson and offers the start-quiz CTA.
class LessonScreen extends StatelessWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    if (courseProv.isLoading || courseProv.course == null) {
      return const LoadingScreen();
    }
    final course = courseProv.course!;
    final decoded = Uri.decodeComponent(lessonId);
    final lesson = _findLesson(course, decoded);
    if (lesson == null) return const _NotFound();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/path'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Title block
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _diffChip(context, lesson.difficulty),
                      const SizedBox(width: 8),
                      _xpChip(context, lesson.xp),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),

            // Explanation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Concept',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lesson.explanation,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.55,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            FormulaCard(formulas: lesson.formulas),

            const SizedBox(height: 12),
            for (var i = 0; i < lesson.examples.length; i++) ...[
              ExampleCard(example: lesson.examples[i], index: i + 1),
              const SizedBox(height: 12),
            ],

            MistakesCard(mistakes: lesson.commonMistakes),
            const SizedBox(height: 24),

            PrimaryButton(
              icon: Icons.quiz_rounded,
              label: 'Start practice quiz',
              onPressed: () => context
                  .push('/quiz/${Uri.encodeComponent(lesson.id)}'),
            ),
          ],
        ),
      ),
    );
  }

  Lesson? _findLesson(Course course, String id) {
    for (final l in course.allLessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  Widget _diffChip(BuildContext context, int d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.signal_cellular_alt_rounded,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text('Difficulty $d',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }

  Widget _xpChip(BuildContext context, int xp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded,
              size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text('+$xp XP',
              style: const TextStyle(
                color: AppColors.warning,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Lesson not found.')),
    );
  }
}
