// lib/screens/path_screen.dart
//
// Vertical scrollable path of lesson nodes, in zigzag layout. Each node
// shows the lesson icon and a star count. Locked lessons are dimmed; the
// next-up unlocked lesson bounces gently. Tapping launches the lesson.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/curriculum.dart';
import '../models/lesson.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PathScreen extends StatelessWidget {
  const PathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();
    final completed = app.progress.completedLessonIds;

    // Find the index of the first incomplete lesson, that's the "next up".
    final allLessons = Curriculum.allLessons;
    int nextUp = -1;
    for (var i = 0; i < allLessons.length; i++) {
      if (!completed.contains(allLessons[i].id)) {
        nextUp = i;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Path'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          for (final unit in Curriculum.units) ...[
            _UnitHeader(unit: unit),
            const SizedBox(height: 8),
            for (var i = 0; i < unit.lessons.length; i++)
              _PathNode(
                lesson: unit.lessons[i],
                position: i % 2 == 0 ? _NodeSide.left : _NodeSide.right,
                completed: completed.contains(unit.lessons[i].id),
                stars: app.progress.lessonStars[unit.lessons[i].id] ?? 0,
                isNext: allLessons.indexOf(unit.lessons[i]) == nextUp,
                locked: _isLocked(unit.lessons[i], allLessons, completed),
              ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  /// A lesson is "locked" if any earlier lesson in the curriculum hasn't been
  /// completed. Lightweight gate — keeps users from skipping ahead.
  bool _isLocked(Lesson l, List<Lesson> all, Set<String> completed) {
    final idx = all.indexOf(l);
    for (var i = 0; i < idx; i++) {
      if (!completed.contains(all[i].id)) return true;
    }
    return false;
  }
}

class _UnitHeader extends StatelessWidget {
  const _UnitHeader({required this.unit});
  final Unit unit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radLarge),
      ),
      child: Row(
        children: [
          Text(unit.icon,
              style: TextStyle(
                  fontSize: 28,
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800)),
                Text(unit.tagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer.withOpacity(0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NodeSide { left, right }

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.lesson,
    required this.position,
    required this.completed,
    required this.stars,
    required this.isNext,
    required this.locked,
  });

  final Lesson lesson;
  final _NodeSide position;
  final bool completed;
  final int stars;
  final bool isNext;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);

    Color nodeColor;
    Color iconColor;
    if (locked) {
      nodeColor = scheme.surfaceContainer;
      iconColor = scheme.onSurfaceVariant.withOpacity(0.5);
    } else if (completed) {
      nodeColor = palette.success;
      iconColor = Colors.white;
    } else if (isNext) {
      nodeColor = scheme.primary;
      iconColor = scheme.onPrimary;
    } else {
      nodeColor = scheme.surfaceContainerHighest;
      iconColor = scheme.onSurface;
    }

    final node = GestureDetector(
      onTap: locked
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Finish earlier lessons first.')),
              );
            }
          : () => context.go('/lesson/${lesson.id}'),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              boxShadow: completed || isNext
                  ? [
                      BoxShadow(
                        color: nodeColor.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: locked
                  ? Icon(Icons.lock_rounded, color: iconColor, size: 32)
                  : completed
                      ? Icon(Icons.check_rounded, color: iconColor, size: 36)
                      : Text(
                          lesson.icon,
                          style: TextStyle(
                              fontSize: 32,
                              color: iconColor,
                              fontWeight: FontWeight.w800),
                        ),
            ),
          ),
          if (completed && stars > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Icon(
                    i < stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 14,
                    color: i < stars
                        ? palette.streak
                        : scheme.outlineVariant,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          SizedBox(
            width: 110,
            child: Text(
              lesson.title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: locked
                      ? scheme.onSurfaceVariant.withOpacity(0.6)
                      : scheme.onSurface),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    final aligned = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (position == _NodeSide.right) const Spacer(),
          isNext
              ? node.animate(
                      onComplete: (c) => c.repeat(reverse: true))
                  .moveY(
                      begin: 0,
                      end: -6,
                      duration: 1100.ms,
                      curve: Curves.easeInOut)
              : node,
          if (position == _NodeSide.left) const Spacer(),
        ],
      ),
    );
    return aligned;
  }
}
