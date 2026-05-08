import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/achievements_screen.dart';
import '../screens/home_screen.dart';
import '../screens/lesson_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/main_shell.dart';
import '../screens/path_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/quiz_result_screen.dart';
import '../screens/review_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';

/// Builds the global [GoRouter]. Root paths host the bottom-nav shell;
/// lesson/quiz routes push fullscreen pages on top.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/loading',
        builder: (_, __) => const LoadingScreen(),
      ),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/path',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: PathScreen(),
            ),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: StatsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, state) => LessonScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/quiz/:id',
        builder: (_, state) => QuizScreen(lessonId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/result',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizResultScreen(
            lessonId: extra['lessonId'] as String,
            correct: extra['correct'] as int,
            total: extra['total'] as int,
            xpEarned: extra['xpEarned'] as int,
          );
        },
      ),
      GoRoute(
        path: '/search',
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (_, __) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/review',
        builder: (_, __) => const ReviewScreen(),
      ),
    ],
  );
}
