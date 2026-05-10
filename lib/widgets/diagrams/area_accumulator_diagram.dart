// lib/widgets/diagrams/area_accumulator_diagram.dart
//
// As x sweeps left→right, area under the curve fills in and a counter
// shows the running total. Visualises integration as accumulation.

import 'package:flutter/material.dart';

import 'graph_helpers.dart';
import '../../models/micro_screen.dart';

class AreaAccumulatorDiagram extends StatefulWidget {
  const AreaAccumulatorDiagram({
    super.key,
    this.controlledX,
    this.func = GraphFunc.linearPos,
    this.a = 0,
    this.b = 2,
    this.autoAnimate = true,
  });

  final double? controlledX;
  final GraphFunc func;
  final double a;
  final double b;
  final bool autoAnimate;

  @override
  State<AreaAccumulatorDiagram> createState() =>
      _AreaAccumulatorDiagramState();
}

class _AreaAccumulatorDiagramState extends State<AreaAccumulatorDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  double _x = 0;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (widget.autoAnimate && widget.controlledX == null) {
      _ac.addListener(() {
        setState(() {
          _x = widget.a + _ac.value * (widget.b - widget.a);
        });
      });
      _ac.repeat();
    } else if (widget.controlledX != null) {
      _x = widget.controlledX!;
    }
  }

  @override
  void didUpdateWidget(covariant AreaAccumulatorDiagram old) {
    super.didUpdateWidget(old);
    if (widget.controlledX != null) _x = widget.controlledX!;
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _AreaPainter(
        x: _x,
        func: widget.func,
        a: widget.a,
        b: widget.b,
        colorScheme: Theme.of(context).colorScheme,
      ),
    );
  }
}

class _AreaPainter extends CustomPainter {
  _AreaPainter({
    required this.x,
    required this.func,
    required this.a,
    required this.b,
    required this.colorScheme,
  });

  final double x;
  final GraphFunc func;
  final double a, b;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = MathBounds(
      xMin: a - 0.4,
      xMax: b + 0.4,
      yMin: -0.5,
      yMax: 3.0,
    );
    final t = GraphTransform(bounds: bounds, size: size);

    drawAxes(
      canvas,
      t,
      axis: colorScheme.outline,
      grid: colorScheme.outlineVariant.withOpacity(0.3),
    );

    // Build the filled area path.
    final path = Path();
    final start = t.toPixel(a, 0);
    path.moveTo(start.dx, start.dy);
    const samples = 80;
    for (var i = 0; i <= samples; i++) {
      final xi = a + i * (x - a) / samples;
      final yi = evalGraph(func, xi);
      final p = t.toPixel(xi, yi);
      path.lineTo(p.dx, p.dy);
    }
    final end = t.toPixel(x, 0);
    path.lineTo(end.dx, end.dy);
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = colorScheme.primary.withOpacity(0.30),
    );

    // The function curve.
    drawFunction(canvas, t, func, colorScheme.primary);

    // Sweeping vertical line at x.
    canvas.drawLine(
      t.toPixel(x, bounds.yMin),
      t.toPixel(x, bounds.yMax),
      Paint()
        ..color = colorScheme.tertiary
        ..strokeWidth = 2,
    );

    // Running total readout.
    final area = integralFromTo(func, a, x);
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'area so far\n',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: area.toStringAsFixed(2),
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final pillRect = Rect.fromLTWH(8, 8, tp.width + 24, tp.height + 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(16)),
      Paint()..color = colorScheme.surfaceContainerHigh,
    );
    tp.paint(canvas, Offset(pillRect.left + 12, pillRect.top + 6));
  }

  @override
  bool shouldRepaint(covariant _AreaPainter old) =>
      old.x != x ||
      old.func != func ||
      old.a != a ||
      old.b != b ||
      old.colorScheme != colorScheme;
}
