// lib/widgets/questions/reorder_question.dart
//
// ReorderableListView. The user drags steps into the right order, then
// taps Check.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import 'question_result.dart';

class ReorderQuestion extends StatefulWidget {
  const ReorderQuestion({
    super.key,
    required this.screen,
    required this.onAnswered,
    required this.hapticsOn,
  });

  final ReorderScreen screen;
  final QuestionAnsweredCallback onAnswered;
  final bool hapticsOn;

  @override
  State<ReorderQuestion> createState() => _ReorderQuestionState();
}

class _ReorderQuestionState extends State<ReorderQuestion> {
  /// Indices into widget.screen.shuffledSteps in the user's current order.
  late List<int> _order;
  bool _submitted = false;
  bool _correct = false;

  @override
  void initState() {
    super.initState();
    final n = widget.screen.shuffledSteps.length;
    _order = List.generate(n, (i) => i);
    _order.shuffle(Random());
    // Avoid the freebie of being already in correct order at start.
    var attempts = 0;
    while (_listEquals(_order, widget.screen.correctOrder) && attempts < 6) {
      _order.shuffle(Random());
      attempts++;
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _submit() {
    final correct = _listEquals(_order, widget.screen.correctOrder);
    setState(() {
      _submitted = true;
      _correct = correct;
    });
    if (widget.hapticsOn) {
      correct
          ? HapticFeedback.lightImpact()
          : HapticFeedback.heavyImpact();
    }
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      widget.onAnswered(correct, correct ? null : widget.screen.solutionHint);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.screen.prompt,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Expanded(
          child: ReorderableListView(
            buildDefaultDragHandles: true,
            onReorder: (oldIdx, newIdx) {
              if (_submitted) return;
              setState(() {
                if (newIdx > oldIdx) newIdx--;
                final v = _order.removeAt(oldIdx);
                _order.insert(newIdx, v);
              });
              if (widget.hapticsOn) HapticFeedback.selectionClick();
            },
            children: [
              for (var pos = 0; pos < _order.length; pos++)
                Padding(
                  key: ValueKey('step-$pos-${_order[pos]}'),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radMedium),
                      border: Border.all(
                          color: scheme.outlineVariant, width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: scheme.primaryContainer,
                          child: Text(
                            '${pos + 1}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.onPrimaryContainer),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.screen.shuffledSteps[_order[pos]],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Icon(Icons.drag_handle_rounded,
                            color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitted ? null : _submit,
            child: const Text('Check order'),
          ),
        ),
      ],
    );
  }
}
