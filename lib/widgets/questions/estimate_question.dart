// lib/widgets/questions/estimate_question.dart
//
// Drag a slider to estimate slope/area. We render a small graph showing
// the relevant feature highlighted at the user's current guess, then
// score within a tolerance band.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import '../diagrams/graph_helpers.dart';
import 'question_result.dart';

class EstimateQuestion extends StatefulWidget {
  const EstimateQuestion({
    super.key,
    required this.screen,
    required this.onAnswered,
    required this.hapticsOn,
  });

  final EstimateScreen screen;
  final QuestionAnsweredCallback onAnswered;
  final bool hapticsOn;

  @override
  State<EstimateQuestion> createState() => _EstimateQuestionState();
}

class _EstimateQuestionState extends State<EstimateQuestion> {
  late double _value;
  bool _submitted = false;
  bool _correct = false;

  @override
  void initState() {
    super.initState();
    _value = (widget.screen.minValue + widget.screen.maxValue) / 2;
  }

  void _submit() {
    final s = widget.screen;
    final tolBand =
        s.tolerance * (s.maxValue - s.minValue).abs().clamp(0.5, double.infinity);
    final ok = (_value - s.correctValue).abs() <= tolBand;
    setState(() {
      _submitted = true;
      _correct = ok;
    });
    if (widget.hapticsOn) {
      ok ? HapticFeedback.lightImpact() : HapticFeedback.heavyImpact();
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      widget.onAnswered(ok, ok ? null : widget.screen.solutionHint);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = widget.screen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.prompt, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radLarge),
            ),
            padding: const EdgeInsets.all(12),
            child: CustomPaint(
              size: Size.infinite,
              painter: _EstimatePainter(
                screen: s,
                guess: _value,
                submitted: _submitted,
                correct: _correct,
                colorScheme: scheme,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTheme.radMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your estimate:',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(_value.toStringAsFixed(2),
                      style: mathStyle(context, size: 20, weight: FontWeight.w800)
                          .copyWith(color: scheme.primary)),
                ],
              ),
              const SizedBox(height: 4),
              Slider(
                value: _value,
                min: s.minValue,
                max: s.maxValue,
                onChanged: _submitted
                    ? null
                    : (v) => setState(() => _value = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitted ? null : _submit,
            child: const Text('Submit estimate'),
          ),
        ),
      ],
    );
  }
}

class _EstimatePainter extends CustomPainter {
  _EstimatePainter({
    required this.screen,
    required this.guess,
    required this.submitted,
    required this.correct,
    required this.colorScheme,
  });

  final EstimateScreen screen;
  final double guess;
  final bool submitted;
  final bool correct;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = defaultBounds(screen.func);
    final t = GraphTransform(bounds: bounds, size: size);
    drawAxes(canvas, t,
        axis: colorScheme.outline,
        grid: colorScheme.outlineVariant.withOpacity(0.3));
    drawFunction(canvas, t, screen.func, colorScheme.primary);

    // Visualise the guess in a kind-specific way.
    switch (screen.estimateKind) {
      case EstimateKind.slopeAtPoint:
      case EstimateKind.derivativeAtPoint:
        // Draw a line of slope `guess` at the parameter x.
        final x = screen.parameter;
        final y = evalGraph(screen.func, x);
        final dx = bounds.width;
        final p1 = t.toPixel(x - dx, y - guess * dx);
        final p2 = t.toPixel(x + dx, y + guess * dx);
        canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = colorScheme.tertiary
            ..strokeWidth = 2.5,
        );
        canvas.drawCircle(t.toPixel(x, y), 7, Paint()..color = colorScheme.tertiary);
        break;
      case EstimateKind.areaUnderCurve:
        // Highlight the region [0, parameter]; user is estimating its area.
        final path = Path();
        final start = t.toPixel(0, 0);
        path.moveTo(start.dx, start.dy);
        const samples = 80;
        for (var i = 0; i <= samples; i++) {
          final x = i * screen.parameter / samples;
          final y = evalGraph(screen.func, x);
          final p = t.toPixel(x, y);
          path.lineTo(p.dx, p.dy);
        }
        path.lineTo(t.toPixel(screen.parameter, 0).dx,
            t.toPixel(screen.parameter, 0).dy);
        path.close();
        canvas.drawPath(
          path,
          Paint()..color = colorScheme.primary.withOpacity(0.30),
        );
        // Show the user's guess as a textual badge already shown in the slider.
        break;
      case EstimateKind.limitValue:
        // Draw a horizontal line at y = guess.
        canvas.drawLine(
          t.toPixel(bounds.xMin, guess),
          t.toPixel(bounds.xMax, guess),
          Paint()
            ..color = colorScheme.tertiary
            ..strokeWidth = 2.5,
        );
        break;
    }

    // After submit, draw the tolerance band centred on correctValue.
    if (submitted) {
      final cv = screen.correctValue;
      final band = screen.tolerance *
          (screen.maxValue - screen.minValue).abs().clamp(0.5, double.infinity);
      final color = correct
          ? Colors.green.withOpacity(0.15)
          : Colors.red.withOpacity(0.15);
      switch (screen.estimateKind) {
        case EstimateKind.slopeAtPoint:
        case EstimateKind.derivativeAtPoint:
          // Show correct slope as a line for reference.
          final x = screen.parameter;
          final y = evalGraph(screen.func, x);
          final dx = bounds.width;
          canvas.drawLine(
            t.toPixel(x - dx, y - cv * dx),
            t.toPixel(x + dx, y + cv * dx),
            Paint()
              ..color = correct
                  ? Colors.green.withOpacity(0.7)
                  : Colors.red.withOpacity(0.7)
              ..strokeWidth = 2.5,
          );
          break;
        case EstimateKind.areaUnderCurve:
          // No additional drawing — readout below conveys the truth.
          break;
        case EstimateKind.limitValue:
          canvas.drawRect(
            Rect.fromLTRB(
              t.toPixel(bounds.xMin, cv + band).dx,
              t.toPixel(bounds.xMin, cv + band).dy,
              t.toPixel(bounds.xMax, cv - band).dx,
              t.toPixel(bounds.xMax, cv - band).dy,
            ),
            Paint()..color = color,
          );
          break;
      }

      // Truth pill.
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'true: ',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            TextSpan(
              text: cv.toStringAsFixed(2),
              style: TextStyle(
                color: correct ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final pillRect = Rect.fromLTWH(8, 8, tp.width + 20, tp.height + 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(pillRect, const Radius.circular(999)),
        Paint()..color = colorScheme.surfaceContainerHigh,
      );
      tp.paint(canvas, Offset(pillRect.left + 10, pillRect.top + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _EstimatePainter old) =>
      old.guess != guess ||
      old.submitted != submitted ||
      old.correct != correct ||
      old.colorScheme != colorScheme;
}
