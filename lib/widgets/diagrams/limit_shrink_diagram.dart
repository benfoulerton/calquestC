// lib/widgets/diagrams/limit_shrink_diagram.dart
//
// Shows x sliding toward a target, with f(x) tracking it in. Used as both
// hook (auto) and explore (slider).

import 'package:flutter/material.dart';

import 'graph_helpers.dart';
import '../../models/micro_screen.dart';

class LimitShrinkDiagram extends StatefulWidget {
  const LimitShrinkDiagram({
    super.key,
    this.controlledX,
    this.targetX = 2.0,
    this.func = GraphFunc.linearPos,
    this.autoAnimate = false,
  });

  final double? controlledX;
  final double targetX;
  final GraphFunc func;
  final bool autoAnimate;

  @override
  State<LimitShrinkDiagram> createState() => _LimitShrinkDiagramState();
}

class _LimitShrinkDiagramState extends State<LimitShrinkDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  double _x = 0.5;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.autoAnimate && widget.controlledX == null) {
      _ac.addListener(() {
        // Ease toward target then jump back.
        setState(() {
          // 0 → target: monotone approach
          final t = Curves.easeInOut.transform(_ac.value);
          _x = 0 + t * widget.targetX;
        });
      });
      _ac.repeat();
    } else if (widget.controlledX != null) {
      _x = widget.controlledX!;
    }
  }

  @override
  void didUpdateWidget(covariant LimitShrinkDiagram old) {
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
      painter: _LimitPainter(
        x: _x,
        targetX: widget.targetX,
        func: widget.func,
        colorScheme: Theme.of(context).colorScheme,
      ),
    );
  }
}

class _LimitPainter extends CustomPainter {
  _LimitPainter({
    required this.x,
    required this.targetX,
    required this.func,
    required this.colorScheme,
  });

  final double x, targetX;
  final GraphFunc func;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = MathBounds(
      xMin: targetX - 2.5,
      xMax: targetX + 1.5,
      yMin: -1,
      yMax: targetX + 2,
    );
    final t = GraphTransform(bounds: bounds, size: size);

    drawAxes(
      canvas,
      t,
      axis: colorScheme.outline,
      grid: colorScheme.outlineVariant.withOpacity(0.3),
    );
    drawFunction(canvas, t, func, colorScheme.primary);

    final y = evalGraph(func, x);
    final tY = evalGraph(func, targetX);

    // Vertical dashed line from x-axis to (x, y).
    _drawDashed(
      canvas,
      t.toPixel(x, 0),
      t.toPixel(x, y),
      colorScheme.tertiary,
    );
    // Horizontal dashed line from y-axis (or left) to (x, y).
    _drawDashed(
      canvas,
      t.toPixel(bounds.xMin, y),
      t.toPixel(x, y),
      colorScheme.tertiary,
    );

    // Target dot at (targetX, tY).
    canvas.drawCircle(
      t.toPixel(targetX, tY),
      6,
      Paint()..color = colorScheme.outlineVariant,
    );

    // Moving dot at (x, y).
    canvas.drawCircle(
      t.toPixel(x, y),
      8,
      Paint()..color = colorScheme.tertiary,
    );

    // Label: x = ..., f(x) = ...
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'x = ${x.toStringAsFixed(2)}\n',
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: 'f(x) = ${y.toStringAsFixed(2)}',
            style: TextStyle(
                color: colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700),
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

  void _drawDashed(Canvas canvas, Offset a, Offset b, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = (dx * dx + dy * dy).abs();
    final len = dist == 0 ? 0 : Offset(dx, dy).distance;
    if (len == 0) return;
    const dash = 5.0;
    const gap = 4.0;
    final stride = dash + gap;
    final ux = dx / len;
    final uy = dy / len;
    var travelled = 0.0;
    while (travelled < len) {
      final x1 = a.dx + ux * travelled;
      final y1 = a.dy + uy * travelled;
      final end = (travelled + dash).clamp(0, len).toDouble();
      final x2 = a.dx + ux * end;
      final y2 = a.dy + uy * end;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      travelled += stride;
    }
  }

  @override
  bool shouldRepaint(covariant _LimitPainter old) =>
      old.x != x ||
      old.targetX != targetX ||
      old.func != func ||
      old.colorScheme != colorScheme;
}
