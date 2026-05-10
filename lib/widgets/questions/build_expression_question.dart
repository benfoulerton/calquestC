// lib/widgets/questions/build_expression_question.dart
//
// Tile bank below; assembled expression on top. Tap a tile to append it
// to the assembled row; tap an assembled tile to remove it. Submit checks
// against correctOrder.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import 'question_result.dart';

class BuildExpressionQuestion extends StatefulWidget {
  const BuildExpressionQuestion({
    super.key,
    required this.screen,
    required this.onAnswered,
    required this.hapticsOn,
  });

  final BuildExpressionScreen screen;
  final QuestionAnsweredCallback onAnswered;
  final bool hapticsOn;

  @override
  State<BuildExpressionQuestion> createState() =>
      _BuildExpressionQuestionState();
}

class _BuildExpressionQuestionState extends State<BuildExpressionQuestion> {
  /// Indices into widget.screen.tiles, in the order the user has chosen.
  final List<int> _assembled = [];
  bool _submitted = false;
  bool _correct = false;

  bool _isUsed(int i) => _assembled.contains(i);

  void _addTile(int i) {
    if (_submitted) return;
    if (_isUsed(i)) return;
    setState(() => _assembled.add(i));
    if (widget.hapticsOn) HapticFeedback.selectionClick();
  }

  void _removeAssembled(int posInAssembled) {
    if (_submitted) return;
    setState(() => _assembled.removeAt(posInAssembled));
    if (widget.hapticsOn) HapticFeedback.selectionClick();
  }

  void _submit() {
    if (_submitted) return;
    final correct = _orderEquals(_assembled, widget.screen.correctOrder);
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

  bool _orderEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
        // Assembled row.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _submitted
                ? (_correct ? palette.successContainer : scheme.errorContainer)
                : scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radLarge),
            border: Border.all(
              color: _submitted
                  ? (_correct ? palette.success : scheme.error)
                  : scheme.outlineVariant,
              width: 2,
            ),
          ),
          child: _assembled.isEmpty
              ? Text(
                  'Tap tiles below to build the expression',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var pos = 0; pos < _assembled.length; pos++)
                      _Tile(
                        text: widget.screen.tiles[_assembled[pos]],
                        onTap: () => _removeAssembled(pos),
                        compact: true,
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 8),
        const Spacer(),
        // Tile bank.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < widget.screen.tiles.length; i++)
              if (!_isUsed(i))
                _Tile(
                  text: widget.screen.tiles[i],
                  onTap: () => _addTile(i),
                ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (_assembled.isNotEmpty)
              TextButton.icon(
                onPressed: _submitted
                    ? null
                    : () {
                        setState(() => _assembled.clear());
                        if (widget.hapticsOn) HapticFeedback.selectionClick();
                      },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Clear'),
              ),
            const Spacer(),
            FilledButton(
              onPressed: _assembled.isEmpty || _submitted ? null : _submit,
              child: const Text('Check'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.text,
    required this.onTap,
    this.compact = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppTheme.radSmall),
          border: Border.all(color: scheme.primary, width: 1.5),
        ),
        child: Text(
          text,
          style: mathStyle(context, size: compact ? 16 : 18,
              weight: FontWeight.w800)
              .copyWith(color: scheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
