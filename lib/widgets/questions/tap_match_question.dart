// lib/widgets/questions/tap_match_question.dart
//
// Two columns of tiles. User taps one on the left, then one on the right.
// If they match (same pair index), they go green and disappear. If not,
// brief red flash and clear selection. Question completes when all paired.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import 'question_result.dart';

class TapMatchQuestion extends StatefulWidget {
  const TapMatchQuestion({
    super.key,
    required this.screen,
    required this.onAnswered,
    required this.hapticsOn,
  });

  final TapMatchScreen screen;
  final QuestionAnsweredCallback onAnswered;
  final bool hapticsOn;

  @override
  State<TapMatchQuestion> createState() => _TapMatchQuestionState();
}

class _TapMatchQuestionState extends State<TapMatchQuestion> {
  // Shuffled left/right tile lists. Each element is the original pair index.
  late List<int> _leftOrder;
  late List<int> _rightOrder;
  // Which left/right pair indices have been matched.
  final Set<int> _matched = {};
  // Currently selected indices into _leftOrder / _rightOrder.
  int? _selL;
  int? _selR;
  // For brief mismatch flash.
  int? _flashL;
  int? _flashR;
  int _wrongPicks = 0;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    final n = widget.screen.pairs.length;
    final r = Random();
    _leftOrder = List.generate(n, (i) => i)..shuffle(r);
    _rightOrder = List.generate(n, (i) => i)..shuffle(r);
  }

  void _checkMatch() {
    if (_selL == null || _selR == null) return;
    final lPair = _leftOrder[_selL!];
    final rPair = _rightOrder[_selR!];
    if (lPair == rPair) {
      // Match!
      if (widget.hapticsOn) HapticFeedback.lightImpact();
      setState(() {
        _matched.add(lPair);
        _selL = null;
        _selR = null;
      });
      if (_matched.length == widget.screen.pairs.length) {
        // All done — report result.
        widget.onAnswered(_wrongPicks == 0, null);
      }
    } else {
      // Mismatch.
      if (widget.hapticsOn) HapticFeedback.heavyImpact();
      setState(() {
        _flashL = _selL;
        _flashR = _selR;
        _wrongPicks++;
      });
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(() {
          _flashL = null;
          _flashR = null;
          _selL = null;
          _selR = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.screen.prompt,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < _leftOrder.length; i++) ...[
                      _Tile(
                        text: widget.screen.pairs[_leftOrder[i]].left,
                        selected: _selL == i,
                        matched: _matched.contains(_leftOrder[i]),
                        flashError: _flashL == i,
                        onTap: () {
                          if (_matched.contains(_leftOrder[i])) return;
                          setState(() {
                            _selL = (_selL == i) ? null : i;
                          });
                          _checkMatch();
                        },
                      ),
                      if (i != _leftOrder.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < _rightOrder.length; i++) ...[
                      _Tile(
                        text: widget.screen.pairs[_rightOrder[i]].right,
                        selected: _selR == i,
                        matched: _matched.contains(_rightOrder[i]),
                        flashError: _flashR == i,
                        onTap: () {
                          if (_matched.contains(_rightOrder[i])) return;
                          setState(() {
                            _selR = (_selR == i) ? null : i;
                          });
                          _checkMatch();
                        },
                      ),
                      if (i != _rightOrder.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.text,
    required this.selected,
    required this.matched,
    required this.flashError,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool matched;
  final bool flashError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);

    Color bg;
    Color fg;
    Color border;
    if (matched) {
      bg = palette.successContainer;
      fg = scheme.onSurface.withOpacity(0.4);
      border = palette.success;
    } else if (flashError) {
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
      border = scheme.error;
    } else if (selected) {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
      border = scheme.primary;
    } else {
      bg = scheme.surfaceContainerHigh;
      fg = scheme.onSurface;
      border = scheme.outlineVariant;
    }

    return GestureDetector(
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.radMedium),
          border: Border.all(color: border, width: 2),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
