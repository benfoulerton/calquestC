// lib/widgets/questions/fill_blank_question.dart
//
// Equation with one blank slot. User taps a token tile to fill it. We
// evaluate immediately on tap. Wrong tiles flash; right tile locks in
// and the answered callback fires.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import 'question_result.dart';

class FillBlankQuestion extends StatefulWidget {
  const FillBlankQuestion({
    super.key,
    required this.screen,
    required this.onAnswered,
    required this.hapticsOn,
  });

  final FillBlankScreen screen;
  final QuestionAnsweredCallback onAnswered;
  final bool hapticsOn;

  @override
  State<FillBlankQuestion> createState() => _FillBlankQuestionState();
}

class _FillBlankQuestionState extends State<FillBlankQuestion> {
  int? _picked;
  bool _locked = false;

  void _onPick(int idx) {
    if (_locked) return;
    setState(() => _picked = idx);
    final correct = idx == widget.screen.correctIndex;
    if (widget.hapticsOn) {
      if (correct) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    }
    _locked = true;
    Future.delayed(const Duration(milliseconds: 350), () {
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
        const SizedBox(height: 24),
        // Equation with blank.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radLarge),
          ),
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                widget.screen.beforeBlank,
                style: mathStyle(context, size: 22, weight: FontWeight.w700),
              ),
              _BlankSlot(
                value: _picked == null
                    ? null
                    : widget.screen.options[_picked!],
              ),
              Text(
                widget.screen.afterBlank,
                style: mathStyle(context, size: 22, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Tap an option:',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < widget.screen.options.length; i++)
              _OptionChip(
                label: widget.screen.options[i],
                state: _picked == i
                    ? (i == widget.screen.correctIndex
                        ? _ChipState.correct
                        : _ChipState.wrong)
                    : _ChipState.idle,
                onTap: () => _onPick(i),
              ),
          ],
        ),
      ],
    );
  }
}

enum _ChipState { idle, correct, wrong }

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _ChipState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);

    Color bg;
    Color fg;
    Color border;
    switch (state) {
      case _ChipState.idle:
        bg = scheme.surfaceContainerHigh;
        fg = scheme.onSurface;
        border = scheme.outlineVariant;
        break;
      case _ChipState.correct:
        bg = palette.successContainer;
        fg = scheme.onSurface;
        border = palette.success;
        break;
      case _ChipState.wrong:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        border = scheme.error;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radPill),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(
          label,
          style: mathStyle(context, size: 16, weight: FontWeight.w700)
              .copyWith(color: fg),
        ),
      ),
    );
  }
}

class _BlankSlot extends StatelessWidget {
  const _BlankSlot({required this.value});
  final String? value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: value == null
            ? scheme.surfaceContainerHigh
            : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radSmall),
        border: Border.all(color: scheme.primary, width: 2),
      ),
      child: Text(
        value ?? ' ? ',
        style: mathStyle(context, size: 22, weight: FontWeight.w800).copyWith(
          color: value == null ? scheme.primary : scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
