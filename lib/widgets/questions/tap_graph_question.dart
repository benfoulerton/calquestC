// lib/widgets/questions/tap_graph_question.dart
//
// 2x2 grid of mini graph tiles. User taps one. Wrong tile flashes red and
// hint shows; right tile lights green and we advance.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import '../diagrams/graph_helpers.dart';
import '../diagrams/mini_graph.dart';
import 'question_result.dart';

class TapGraphQuestion extends StatefulWidget {
  const TapGraphQuestion({
    super.key,
    required this.screen,
    required this.onAnswered,
    required this.hapticsOn,
  });

  final TapGraphScreen screen;
  final QuestionAnsweredCallback onAnswered;
  final bool hapticsOn;

  @override
  State<TapGraphQuestion> createState() => _TapGraphQuestionState();
}

class _TapGraphQuestionState extends State<TapGraphQuestion> {
  int? _picked;
  bool _locked = false;

  void _onPick(int idx) {
    if (_locked) return;
    setState(() => _picked = idx);
    final correct = idx == widget.screen.correctIndex;
    if (widget.hapticsOn) {
      correct
          ? HapticFeedback.lightImpact()
          : HapticFeedback.heavyImpact();
    }
    _locked = true;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      widget.onAnswered(correct, correct ? null : widget.screen.solutionHint);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.screen.prompt,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: widget.screen.options.length,
            itemBuilder: (context, i) => _GraphTile(
              func: widget.screen.options[i],
              state: _picked == i
                  ? (i == widget.screen.correctIndex
                      ? _TileState.correct
                      : _TileState.wrong)
                  : _TileState.idle,
              onTap: () => _onPick(i),
            ),
          ),
        ),
      ],
    );
  }
}

enum _TileState { idle, correct, wrong }

class _GraphTile extends StatelessWidget {
  const _GraphTile({
    required this.func,
    required this.state,
    required this.onTap,
  });

  final GraphFunc func;
  final _TileState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);

    Color bg;
    Color border;
    switch (state) {
      case _TileState.idle:
        bg = scheme.surfaceContainerHigh;
        border = scheme.outlineVariant;
        break;
      case _TileState.correct:
        bg = palette.successContainer;
        border = palette.success;
        break;
      case _TileState.wrong:
        bg = scheme.errorContainer;
        border = scheme.error;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radLarge),
          border: Border.all(color: border, width: 2.5),
        ),
        padding: const EdgeInsets.all(8),
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: MiniGraph(func: func, size: 200),
          ),
        ),
      ),
    );
  }
}
