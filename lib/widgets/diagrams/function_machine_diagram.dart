// lib/widgets/diagrams/function_machine_diagram.dart
//
// Animated visual: numbers fly into a box labelled f, get transformed,
// and fly out. Pure cosmetic hook diagram — pedagogically anchors the
// "function as machine" mental model.

import 'dart:math' as math;
import 'package:flutter/material.dart';

class FunctionMachineDiagram extends StatefulWidget {
  const FunctionMachineDiagram({super.key, this.autoAnimate = true});

  final bool autoAnimate;

  @override
  State<FunctionMachineDiagram> createState() =>
      _FunctionMachineDiagramState();
}

class _FunctionMachineDiagramState extends State<FunctionMachineDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  // Three balls cycle through the machine staggered.
  final _values = const [3, 5, 8];
  final _outputs = const [6, 10, 16]; // f(x) = 2x

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.autoAnimate) _ac.repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _MachinePainter(
            t: _ac.value,
            values: _values,
            outputs: _outputs,
            colorScheme: Theme.of(context).colorScheme,
          ),
        );
      },
    );
  }
}

class _MachinePainter extends CustomPainter {
  _MachinePainter({
    required this.t,
    required this.values,
    required this.outputs,
    required this.colorScheme,
  });

  final double t;
  final List<int> values;
  final List<int> outputs;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final cx = size.width / 2;
    final boxW = size.width * 0.35;
    final boxH = size.height * 0.45;
    final boxRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: boxW,
      height: boxH,
    );
    final boxRRect = RRect.fromRectAndRadius(boxRect, const Radius.circular(20));

    // Box.
    canvas.drawRRect(
      boxRRect,
      Paint()..color = colorScheme.primary,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: 'f(x) = 2x',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(cx - tp.width / 2, cy - tp.height / 2),
    );

    // Three balls staggered phase.
    for (var i = 0; i < values.length; i++) {
      final phase = (t + i / values.length) % 1.0;
      _drawBall(canvas, size, boxRect, phase, values[i], outputs[i]);
    }
  }

  void _drawBall(
    Canvas canvas,
    Size size,
    Rect box,
    double phase,
    int input,
    int output,
  ) {
    // Phase 0..1:
    //   0.0–0.4: travel left → box (input ball)
    //   0.4–0.5: inside box (invisible, "transforming")
    //   0.5–1.0: travel box → right (output ball)
    final cy = size.height / 2;
    final padding = 24.0;
    final entryStart = Offset(padding, cy);
    final entryEnd = Offset(box.left, cy);
    final exitStart = Offset(box.right, cy);
    final exitEnd = Offset(size.width - padding, cy);

    Offset pos;
    int label;
    Color color;
    if (phase < 0.4) {
      final p = (phase / 0.4).clamp(0, 1).toDouble();
      pos = Offset.lerp(entryStart, entryEnd, p)!;
      label = input;
      color = colorScheme.tertiary;
    } else if (phase < 0.5) {
      return; // hidden during transformation
    } else {
      final p = ((phase - 0.5) / 0.5).clamp(0, 1).toDouble();
      pos = Offset.lerp(exitStart, exitEnd, p)!;
      label = output;
      color = colorScheme.secondary;
    }

    canvas.drawCircle(pos, 22, Paint()..color = color);
    canvas.drawCircle(
      pos,
      22,
      Paint()
        ..color = colorScheme.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '$label',
        style: TextStyle(
          color: colorScheme.onTertiary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _MachinePainter old) => true;
}
