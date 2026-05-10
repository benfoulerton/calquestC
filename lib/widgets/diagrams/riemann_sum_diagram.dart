// lib/widgets/diagrams/riemann_sum_diagram.dart
//
// Drag a slider to set n (number of rectangles); rectangles fill the area
// under y = x² on [0, 2]. Shows the gap between sum and true area shrinking.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'graph_helpers.dart';
import '../../models/micro_screen.dart';

class RiemannSumDiagram extends StatefulWidget {
  const RiemannSumDiagram({
    super.key,
    this.controlledN,
    this.func = GraphFunc.parabolaUp,
    this.a = 0,
    this.b = 2,
    this.autoAnimate = false,
  });

  final double? controlledN;
  final GraphFunc func;
  final double a;
  final double b;
  final bool autoAnimate;

  @override
  State<RiemannSumDiagram> createState() => _RiemannSumDiagramState();
}

class _RiemannSumDiagramState extends State<RiemannSumDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  double _autoN = 4;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (widget.autoAnimate) {
      _ac.repeat();
      _ac.addListener(_tick);
    }
  }

  void _tick() {
    setState(() {
      // Ramp from 2 → 32 → repeat.
      _autoN = 2 + 30 * _ac.value;
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = (widget.controlledN ?? _autoN).round();
    return CustomPaint(
      size: Size.infinite,
      painter: _RiemannPainter(
        n: n,
        func: widget.func,
        a: widget.a,
        b: widget.b,
        colorScheme: Theme.of(context).colorScheme,
      ),
    );
  }
}

class _RiemannPainter extends CustomPainter {
  _RiemannPainter({
    required this.n,
    required this.func,
    required this.a,
    required this.b,
    required this.colorScheme,
  });

  final int n;
  final GraphFunc func;
  final double a, b;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    // Bounds tweak: pad the y range a bit above the function max in [a,b].
    final fMax = _maxOnInterval(func, a, b);
    final bounds = MathBounds(
      xMin: a - 0.4,
      xMax: b + 0.4,
      yMin: -0.5,
      yMax: fMax * 1.15 + 0.3,
    );
    final t = GraphTransform(bounds: bounds, size: size);
    drawAxes(
      canvas,
      t,
      axis: colorScheme.outline,
      grid: colorScheme.outlineVariant.withOpacity(0.3),
    );

    // Draw rectangles (left endpoint Riemann).
    final rectPaint = Paint()
      ..color = colorScheme.primary.withOpacity(0.30)
      ..style = PaintingStyle.fill;
    final rectStroke = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dx = (b - a) / n;
    var sum = 0.0;
    for (var i = 0; i < n; i++) {
      final xi = a + i * dx;
      final h = evalGraph(func, xi).clamp(0, double.infinity).toDouble();
      sum += h * dx;
      final tl = t.toPixel(xi, h);
      final br = t.toPixel(xi + dx, 0);
      final r = Rect.fromPoints(tl, br);
      canvas.drawRect(r, rectPaint);
      canvas.drawRect(r, rectStroke);
    }

    // Draw the true curve on top.
    drawFunction(canvas, t, func, colorScheme.tertiary, strokeWidth: 3.0);

    // Pill: n and approximate area.
    final actual = integralFromTo(func, a, b);
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'n = $n   ',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'sum ≈ ${sum.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '  /  exact ${actual.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final pillRect = Rect.fromLTWH(
      8,
      8,
      tp.width + 20,
      tp.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(999)),
      Paint()..color = colorScheme.surfaceContainerHigh,
    );
    tp.paint(canvas, Offset(pillRect.left + 10, pillRect.top + 4));
  }

  double _maxOnInterval(GraphFunc f, double a, double b) {
    var m = -double.infinity;
    const samples = 50;
    for (var i = 0; i <= samples; i++) {
      final x = a + i * (b - a) / samples;
      final y = evalGraph(f, x);
      if (!y.isNaN && y > m) m = y;
    }
    return math.max(m, 1.0);
  }

  @override
  bool shouldRepaint(covariant _RiemannPainter old) =>
      old.n != n || old.func != func || old.a != a || old.b != b ||
      old.colorScheme != colorScheme;
}
