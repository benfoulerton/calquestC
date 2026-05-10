// lib/widgets/questions/mcq_question.dart
//
// 4 large pill-button options. User taps one, presses Check (or auto-checks
// if they re-tap). Wrong answer surfaces the option's specific
// misconceptionNote (if any), else the screen's solutionHint.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import 'question_result.dart';

class McqQuestion extends StatefulWidget {
  const McqQuestion({
    super.key,
    required this.screen,
    required this.onAnswered,
    required this.hapticsOn,
  });

  final McqScreen screen;
  final QuestionAnsweredCallback onAnswered;
  final bool hapticsOn;

  @override
  State<McqQuestion> createState() => _McqQuestionState();
}

class _McqQuestionState extends State<McqQuestion> {
  int? _picked;
  bool _submitted = false;
  bool _correct = false;

  void _submit() {
    if (_picked == null || _submitted) return;
    final correct = _picked == widget.screen.correctIndex;
    setState(() {
      _submitted = true;
      _correct = correct;
    });
    if (widget.hapticsOn) {
      correct
          ? HapticFeedback.lightImpact()
          : HapticFeedback.heavyImpact();
    }
    final hint = correct
        ? null
        : widget.screen.options[_picked!].misconceptionNote ??
            widget.screen.solutionHint;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      widget.onAnswered(correct, hint);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.screen.prompt,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: widget.screen.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final isPicked = _picked == i;
              final isCorrect = i == widget.screen.correctIndex;
              Color bg;
              Color border;
              Color fg = scheme.onSurface;
              if (_submitted) {
                if (isCorrect) {
                  bg = palette.successContainer;
                  border = palette.success;
                } else if (isPicked) {
                  bg = scheme.errorContainer;
                  border = scheme.error;
                  fg = scheme.onErrorContainer;
                } else {
                  bg = scheme.surfaceContainerHigh;
                  border = scheme.outlineVariant;
                  fg = scheme.onSurfaceVariant;
                }
              } else {
                if (isPicked) {
                  bg = scheme.primaryContainer;
                  border = scheme.primary;
                  fg = scheme.onPrimaryContainer;
                } else {
                  bg = scheme.surfaceContainerHigh;
                  border = scheme.outlineVariant;
                }
              }
              return GestureDetector(
                onTap: _submitted
                    ? null
                    : () => setState(() => _picked = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppTheme.radLarge),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Text(
                    widget.screen.options[i].label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _picked == null || _submitted ? null : _submit,
            child: const Text('Check'),
          ),
        ),
      ],
    );
  }
}
