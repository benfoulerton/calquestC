// lib/screens/lesson_runner_screen.dart
//
// The screen that walks a user through a Lesson's micro-screens. Top has
// a close button + segmented progress bar (one segment per question);
// body dispatches to the right widget; bottom shows feedback strip on
// wrong/right answers.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../models/micro_screen.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/questions/build_expression_question.dart';
import '../widgets/questions/estimate_question.dart';
import '../widgets/questions/fill_blank_question.dart';
import '../widgets/questions/mcq_question.dart';
import '../widgets/questions/passive_screens.dart';
import '../widgets/questions/reorder_question.dart';
import '../widgets/questions/tap_graph_question.dart';
import '../widgets/questions/tap_match_question.dart';

class LessonRunnerScreen extends StatefulWidget {
  const LessonRunnerScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonRunnerScreen> createState() => _LessonRunnerScreenState();
}

class _LessonRunnerScreenState extends State<LessonRunnerScreen> {
  /// Working list of screens — may have items requeued at end on wrong.
  late List<MicroScreen> _queue;
  int _idx = 0;

  /// Per-itemId result, summarised across attempts (last attempt wins).
  final Map<String, bool> _itemResults = {};

  /// Number of question screens originally in the lesson (for progress bar).
  late int _totalQuestions;

  /// Question screens correctly answered so far.
  int _questionsCorrect = 0;
  int _questionsAnswered = 0;

  /// Feedback shown after a question.
  _Feedback? _feedback;

  /// Whether the current screen has already been answered (we wait for the
  /// feedback to clear before moving on).
  bool _waitingToAdvance = false;

  /// Track which screen indices we've already requeued, so we don't requeue
  /// the same one twice.
  final Set<int> _requeuedOriginalIndices = {};

  @override
  void initState() {
    super.initState();
    _queue = List.of(widget.lesson.screens);
    _totalQuestions = widget.lesson.questionCount;
  }

  MicroScreen get _current => _queue[_idx];

  void _onPassiveContinue() {
    setState(() {
      _idx++;
    });
    _maybeFinish();
  }

  void _onAnswered(bool correct, String? hint) {
    if (_waitingToAdvance) return;
    final s = _current;

    // Record per-item result. If an item is asked twice and gets correct on
    // retry, that counts as correct.
    final prior = _itemResults[s.itemId];
    if (prior == null || correct) {
      _itemResults[s.itemId] = correct;
    }
    _questionsAnswered++;
    if (correct) _questionsCorrect++;

    setState(() {
      _feedback = _Feedback(correct: correct, hint: hint);
      _waitingToAdvance = true;
    });

    // If wrong AND we haven't already requeued this item, append it once
    // more for end-of-lesson retry.
    if (!correct) {
      final origIdx = widget.lesson.screens.indexOf(s);
      if (origIdx >= 0 && !_requeuedOriginalIndices.contains(origIdx)) {
        _requeuedOriginalIndices.add(origIdx);
        _queue.add(s);
      }
    }
  }

  void _continueAfterFeedback() {
    setState(() {
      _feedback = null;
      _waitingToAdvance = false;
      _idx++;
    });
    _maybeFinish();
  }

  void _maybeFinish() async {
    if (_idx >= _queue.length) {
      // Done. Compute and persist results.
      final app = context.read<AppState>();
      await app.recordLessonResult(
        lesson: widget.lesson,
        correct: _questionsCorrect,
        total: _questionsAnswered.clamp(1, 1 << 30),
        itemResults: _itemResults,
      );
      if (!mounted) return;
      // Surprise chest every 5th lesson completion.
      final n = app.progress.completedLessonIds.length;
      final showChest = n > 0 && n % 5 == 0;
      context.go('/result', extra: {
        'lessonId': widget.lesson.id,
        'correct': _questionsCorrect,
        'total': _questionsAnswered,
        'showChest': showChest,
      });
    }
  }

  Widget _buildBody() {
    final app = context.watch<AppState>();
    final s = _current;
    switch (s.kind) {
      case ScreenKind.visualHook:
        return HookScreenView(
          screen: s as HookScreen,
          onContinue: _onPassiveContinue,
        );
      case ScreenKind.exploreSlider:
        return ExploreScreenView(
          screen: s as ExploreScreen,
          onContinue: _onPassiveContinue,
        );
      case ScreenKind.workedExample:
        return WorkedExampleView(
          screen: s as WorkedExampleScreen,
          onContinue: _onPassiveContinue,
        );
      case ScreenKind.summary:
        return SummaryScreenView(
          screen: s as SummaryScreen,
          onContinue: _onPassiveContinue,
        );
      case ScreenKind.tapMatch:
        return TapMatchQuestion(
          screen: s as TapMatchScreen,
          onAnswered: _onAnswered,
          hapticsOn: app.progress.hapticsOn,
        );
      case ScreenKind.fillBlank:
        return FillBlankQuestion(
          screen: s as FillBlankScreen,
          onAnswered: _onAnswered,
          hapticsOn: app.progress.hapticsOn,
        );
      case ScreenKind.tapGraph:
        return TapGraphQuestion(
          screen: s as TapGraphScreen,
          onAnswered: _onAnswered,
          hapticsOn: app.progress.hapticsOn,
        );
      case ScreenKind.estimate:
        return EstimateQuestion(
          screen: s as EstimateScreen,
          onAnswered: _onAnswered,
          hapticsOn: app.progress.hapticsOn,
        );
      case ScreenKind.buildExpression:
        return BuildExpressionQuestion(
          screen: s as BuildExpressionScreen,
          onAnswered: _onAnswered,
          hapticsOn: app.progress.hapticsOn,
        );
      case ScreenKind.reorderSteps:
        return ReorderQuestion(
          screen: s as ReorderScreen,
          onAnswered: _onAnswered,
          hapticsOn: app.progress.hapticsOn,
        );
      case ScreenKind.multipleChoice:
        return McqQuestion(
          screen: s as McqScreen,
          onAnswered: _onAnswered,
          hapticsOn: app.progress.hapticsOn,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keyed body for animated transitions between screens.
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              // Top bar: close + segmented progress.
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () async {
                      final ok = await _confirmExit(context);
                      if (ok && context.mounted) context.go('/');
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SegmentedProgress(
                      total: _totalQuestions,
                      done: _questionsAnswered,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey('screen-$_idx'),
                    child: _buildBody(),
                  ),
                ),
              ),
              // Feedback strip.
              if (_feedback != null)
                _FeedbackStrip(
                  feedback: _feedback!,
                  onContinue: _continueAfterFeedback,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit lesson?'),
        content: const Text(
            'Your progress in this lesson won\'t be saved if you quit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
                backgroundColor: scheme.errorContainer,
                foregroundColor: scheme.onErrorContainer),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _Feedback {
  const _Feedback({required this.correct, this.hint});
  final bool correct;
  final String? hint;
}

class _FeedbackStrip extends StatelessWidget {
  const _FeedbackStrip({required this.feedback, required this.onContinue});
  final _Feedback feedback;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);
    final bg = feedback.correct ? palette.successContainer : scheme.errorContainer;
    final fg = feedback.correct ? palette.success : scheme.error;
    final icon = feedback.correct
        ? Icons.check_circle_rounded
        : Icons.lightbulb_rounded;
    final title = feedback.correct ? 'Nice!' : 'Not quite.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: fg, fontWeight: FontWeight.w800)),
                if (feedback.hint != null) ...[
                  const SizedBox(height: 2),
                  Text(feedback.hint!,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).moveY(begin: 12, end: 0);
  }
}

class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({required this.total, required this.done});
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final n = total <= 0 ? 1 : total;
    final filled = done.clamp(0, n);
    return Row(
      children: [
        for (var i = 0; i < n; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 8,
              decoration: BoxDecoration(
                color: i < filled
                    ? scheme.primary
                    : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (i < n - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
