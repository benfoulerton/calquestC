// lib/widgets/diagrams/secant_to_tangent_diagram.dart
//
// Animated: two points on y = x², connected by a secant. As h shrinks,
// the secant rotates into the tangent.

import 'package:flutter/material.dart';

import 'graph_helpers.dart';
import '../../models/micro_screen.dart';

class SecantToTangentDiagram extends StatefulWidget {
  const SecantToTangentDiagram({
    super.key,
    this.controlledH,
    this.func = GraphFunc.parabolaUp,
    this.fixedX = 1.0,
    this.autoAnimate = false,
  });

  final double? controlledH;
  final GraphFunc func;
  final double fixedX;
  final bool autoAnimate;

  @override
  State<SecantToTangentDiagram> createState() =>
      _SecantToTangentDiagramState();
}

class _SecantToTangentDiagramState extends State<SecantToTangentDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  double _h = 1.5;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.autoAnimate && widget.controlledH == null) {
      _ac.addListener(() {
        // h ramps from 1.5 down to 0.05.
        setState(() {
          final t = _ac.value;
          _h = 0.05 + (1 - t) * 1.45;
        });
      });
      _ac.repeat();
    } else if (widget.controlledH != null) {
      _h = widget.controlledH!;
    }
  }

  @override
  void didUpdateWidget(covariant SecantToTangentDiagram old) {
    super.didUpdateWidget(old);
    if (widget.controlledH != null) _h = widget.controlledH!;
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
      painter: _SecantPainter(
        h: _h,
        x: widget.fixedX,
        func: widget.func,
        colorScheme: Theme.of(context).colorScheme,
      ),
    );
  }
}

class _SecantPainter extends CustomPainter {
  _SecantPainter({
    required this.h,
    required this.x,
    required this.func,
    required this.colorScheme,
  });

  final double h, x;
  final GraphFunc func;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = MathBounds(
      xMin: x - 2.5,
      xMax: x + 2.5,
      yMin: -1,
      yMax: (x + 2) * (x + 2),
    );
    final t = GraphTransform(bounds: bounds, size: size);

    drawAxes(
      canvas,
      t,
      axis: colorScheme.outline,
      grid: colorScheme.outlineVariant.withOpacity(0.3),
    );
    drawFunction(canvas, t, func, colorScheme.primary);

    final y1 = evalGraph(func, x);
    final y2 = evalGraph(func, x + h);
    final p1 = t.toPixel(x, y1);
    final p2 = t.toPixel(x + h, y2);

    // Secant line — extend slightly beyond p1 and p2.
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = (dx * dx + dy * dy);
    if (len > 0) {
      final extend = 0.5;
      final ext1 = Offset(p1.dx - dx * extend, p1.dy - dy * extend);
      final ext2 = Offset(p2.dx + dx * extend, p2.dy + dy * extend);
      canvas.drawLine(
        ext1,
        ext2,
        Paint()
          ..color = colorScheme.tertiary
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // The two points.
    canvas.drawCircle(p1, 8, Paint()..color = colorScheme.tertiary);
    canvas.drawCircle(p2, 8, Paint()..color = colorScheme.secondary);

    // Slope readout: (f(x+h) − f(x)) / h
    final m = (y2 - y1) / h;
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'h = ${h.toStringAsFixed(2)}\n',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: 'slope ≈ ${m.toStringAsFixed(2)}',
            style: TextStyle(
              color: colorScheme.tertiary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final pillRect = Rect.fromLTWH(8, 8, tp.width + 20, tp.height + 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(16)),
      Paint()..color = colorScheme.surfaceContainerHigh,
    );
    tp.paint(canvas, Offset(pillRect.left + 10, pillRect.top + 6));
  }

  @override
  bool shouldRepaint(covariant _SecantPainter old) =>
      old.h != h || old.x != x || old.func != func ||
      old.colorScheme != colorScheme;
}
