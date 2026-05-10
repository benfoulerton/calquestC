// lib/utils/app_router.dart
//
// go_router setup. Three routes:
//   /                  → MainShell (bottom nav)
//   /lesson/:id        → LessonRunnerScreen
//   /result            → LessonResultScreen (extras carry the data)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/curriculum.dart';
import '../models/lesson.dart';
import '../screens/lesson_result_screen.dart';
import '../screens/lesson_runner_screen.dart';
import '../screens/main_shell.dart';
import '../screens/review_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const MainShell(),
    ),
    GoRoute(
      path: '/lesson/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        // First check synthetic review lessons; then static curriculum.
        final Lesson? lesson =
            lookupReviewLesson(id) ?? Curriculum.findById(id);
        if (lesson == null) {
          return _NotFoundScreen(message: 'Lesson "$id" not found.');
        }
        return LessonRunnerScreen(lesson: lesson);
      },
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return LessonResultScreen(
          lessonId: extra['lessonId'] as String? ?? '',
          correct: extra['correct'] as int? ?? 0,
          total: extra['total'] as int? ?? 1,
          showChest: extra['showChest'] as bool? ?? false,
        );
      },
    ),
  ],
);

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56),
              const SizedBox(height: 16),
              Text(message,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Back home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
