import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

/// The course map: each chapter is a section, lessons inside it are nodes
/// arranged in a gentle Duolingo-style zig-zag. Locked / unlocked state
/// follows from `ProgressProvider.isUnlocked`.
class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    final progressProv = context.watch<ProgressProvider>();

    if (courseProv.isLoading || courseProv.course == null) {
      return const LoadingScreen();
    }
    final course = courseProv.course!;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Course path',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => context.push('/search'),
              ),
            ],
          ),
          for (final unit in course.units)
            _UnitSliver(course: course, unit: unit, progress: progressProv),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _UnitSliver extends StatelessWidget {
  final Course course;
  final Unit unit;
  final ProgressProvider progress;
  const _UnitSliver({
    required this.course,
    required this.unit,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final lessons = unit.lessons;
    final completed =
        lessons.where((l) => progress.isCompleted(l)).length;
    return SliverList(
      delegate: SliverChildListDelegate([
        // Unit header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.accent.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHAPTER ${unit.unitNumber}',
                style: const TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.5,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unit.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: lessons.isEmpty
                            ? 0
                            : completed / lessons.length,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$completed/${lessons.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lesson nodes in a zig-zag.
        for (var i = 0; i < lessons.length; i++)
          _PathNode(
            lesson: lessons[i],
            indexInUnit: i,
            unlocked: progress.isUnlocked(course, lessons[i]),
            completed: progress.isCompleted(lessons[i]),
            stars: progress.progress.lessonStars[lessons[i].id] ?? 0,
          ),
      ]),
    );
  }
}

/// Single lesson node: a circular tappable indicator on a zig-zag path,
/// colour-coded by state (locked / current / completed).
class _PathNode extends StatelessWidget {
  final Lesson lesson;
  final int indexInUnit;
  final bool unlocked;
  final bool completed;
  final int stars;

  const _PathNode({
    required this.lesson,
    required this.indexInUnit,
    required this.unlocked,
    required this.completed,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    // Zig-zag: alternate left/right offset.
    final offsetSign = (indexInUnit % 4 < 2) ? 1.0 : -1.0;
    final offset = offsetSign * (indexInUnit % 2 == 0 ? 36.0 : 12.0);

    final Color nodeColor;
    final IconData icon;
    if (completed) {
      nodeColor = AppColors.success;
      icon = Icons.check_rounded;
    } else if (!unlocked) {
      nodeColor = AppColors.lockedNode;
      icon = Icons.lock_rounded;
    } else {
      nodeColor = AppColors.primary;
      icon = Icons.play_arrow_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spacer to create zig-zag.
          if (offset > 0) SizedBox(width: offset.abs()),
          GestureDetector(
            onTap: !unlocked
                ? () => _showLockedSnack(context)
                : () => context
                    .push('/lesson/${Uri.encodeComponent(lesson.id)}'),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    boxShadow: unlocked
                        ? [
                            BoxShadow(
                              color: nodeColor.withOpacity(0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 6),
                if (completed)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      3,
                      (i) => Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppColors.warning,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: !unlocked
                  ? () => _showLockedSnack(context)
                  : () => context
                      .push('/lesson/${Uri.encodeComponent(lesson.id)}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: unlocked
                              ? null
                              : AppColors.textFaint,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Difficulty ${lesson.difficulty} · +${lesson.xp} XP',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.textFaint,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (offset < 0) SizedBox(width: offset.abs()),
        ],
      ),
    );
  }

  void _showLockedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complete the previous lesson to unlock this one.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
