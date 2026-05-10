// lib/screens/review_screen.dart
//
// Lists items the FSRS-lite scheduler thinks are due. Tapping starts a
// "review session" — a synthetic lesson that pulls only the relevant
// micro-screens from the curriculum.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/curriculum.dart';
import '../models/lesson.dart';
import '../models/micro_screen.dart';
import '../models/user_progress.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();
    final due = app.dueReviewItems();

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: due.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.spa_rounded,
                        size: 56, color: scheme.tertiary),
                    const SizedBox(height: 16),
                    Text('Nothing to review yet',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Finish a few lessons and items will queue up for spaced repetition here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radLarge),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.replay_rounded,
                          color: scheme.onTertiaryContainer, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${due.length} item${due.length == 1 ? '' : 's'} ready',
                                style:
                                    Theme.of(context).textTheme.titleLarge),
                            Text(
                              'Re-test these now to lock them in.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _startReviewSession(context, due, app),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Start review (${due.length.clamp(1, 10)})'),
                ),
                const SizedBox(height: 24),
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final r in due)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radMedium),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: r.lapses > 0
                                ? scheme.error
                                : scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.itemId,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall),
                              Text(
                                'Stability: ${r.stabilityDays.toStringAsFixed(1)}d · Lapses: ${r.lapses}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  void _startReviewSession(
      BuildContext context, List<ReviewItem> due, AppState app) {
    // Pull up to 10 due itemIds, find one MicroScreen per itemId from any
    // lesson in the curriculum, build a synthetic Lesson, navigate.
    final wantedIds = due.take(10).map((r) => r.itemId).toSet();
    final picked = <MicroScreen>[];
    for (final l in Curriculum.allLessons) {
      for (final s in l.screens) {
        if (s.isQuestion && wantedIds.contains(s.itemId)) {
          picked.add(s);
          wantedIds.remove(s.itemId);
        }
        if (wantedIds.isEmpty) break;
      }
      if (wantedIds.isEmpty) break;
    }
    if (picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No matching practice items found in curriculum.')),
      );
      return;
    }
    final synthetic = Lesson(
      id: 'review-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Quick review',
      subtitle: 'Spaced repetition',
      icon: '↺',
      screens: [
        ...picked,
        SummaryScreen(
          itemId: 'review-summary',
          title: 'Review done',
          takeaway: 'Items refreshed. They\'ll be back when needed.',
        ),
      ],
      xpReward: 6,
    );
    // Stash the lesson on the router so it can be played by id.
    _ReviewLessonRegistry.put(synthetic);
    context.go('/lesson/${synthetic.id}');
  }
}

/// In-memory registry for synthetic review lessons. The router consults
/// it before falling back to the static curriculum.
class _ReviewLessonRegistry {
  _ReviewLessonRegistry._();
  static final Map<String, Lesson> _byId = {};
  static void put(Lesson l) => _byId[l.id] = l;
  static Lesson? get(String id) => _byId[id];
}

/// Public accessor used by the router.
Lesson? lookupReviewLesson(String id) => _ReviewLessonRegistry.get(id);
