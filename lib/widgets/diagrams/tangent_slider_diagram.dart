// lib/widgets/diagrams/tangent_slider_diagram.dart
//
// Interactive: drag a point along y = x², watch the tangent line and slope
// number update. Also runs as a hook (auto-animates if no slider provided).

import 'package:flutter/material.dart';
import 'graph_helpers.dart';
import '../../models/micro_screen.dart';

class TangentSliderDiagram extends StatefulWidget {
  const TangentSliderDiagram({
    super.key,
    this.controlledX,
    this.func = GraphFunc.parabolaUp,
    this.autoAnimate = false,
  });

  /// If non-null, the diagram uses this externally controlled x position
  /// (e.g. driven by an ExploreScreen slider). If null, the user can drag
  /// a finger to scrub along the curve directly.
  final double? controlledX;

  final GraphFunc func;

  /// If true and [controlledX] is null, automatically animates left↔right.
  final bool autoAnimate;

  @override
  State<TangentSliderDiagram> createState() => _TangentSliderDiagramState();
}

class _TangentSliderDiagramState extends State<TangentSliderDiagram>
    with SingleTickerProviderStateMixin {
  double _x = 0.5;
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    if (widget.autoAnimate && widget.controlledX == null) {
      _ac.repeat(reverse: true);
      _ac.addListener(_tick);
    }
  }

  void _tick() {
    final bounds = defaultBounds(widget.func);
    setState(() {
      _x = bounds.xMin + _ac.value * (bounds.xMax - bounds.xMin);
    });
  }

  @override
  void didUpdateWidget(covariant TangentSliderDiagram old) {
    super.didUpdateWidget(old);
    if (widget.controlledX != null) {
      _x = widget.controlledX!;
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bounds = defaultBounds(widget.func);
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: widget.controlledX != null
              ? null
              : (details) {
                  final t = GraphTransform(
                    bounds: bounds,
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  );
                  setState(() {
                    _x = t
                        .toMathX(details.localPosition.dx)
                        .clamp(bounds.xMin, bounds.xMax);
                  });
                },
          child: CustomPaint(
            size: Size.infinite,
            painter: _TangentPainter(
              x: widget.controlledX ?? _x,
              func: widget.func,
              bounds: bounds,
              colorScheme: Theme.of(context).colorScheme,
            ),
          ),
        );
      },
    );
  }
}

class _TangentPainter extends CustomPainter {
  _TangentPainter({
    required this.x,
    required this.func,
    required this.bounds,
    required this.colorScheme,
  });

  final double x;
  final GraphFunc func;
  final MathBounds bounds;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final t = GraphTransform(bounds: bounds, size: size);
    drawAxes(
      canvas,
      t,
      axis: colorScheme.outline,
      grid: colorScheme.outlineVariant.withOpacity(0.3),
    );
    drawFunction(canvas, t, func, colorScheme.primary);

    // Compute the tangent at x.
    final y = evalGraph(func, x);
    final m = slopeAt(func, x);
    final point = t.toPixel(x, y);

    // Draw the tangent line across the visible width.
    final tangentPaint = Paint()
      ..color = colorScheme.tertiary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final dx = bounds.width;
    final p1 = t.toPixel(x - dx, y - m * dx);
    final p2 = t.toPixel(x + dx, y + m * dx);
    canvas.drawLine(p1, p2, tangentPaint);

    // Draw the moving point.
    canvas.drawCircle(
      point,
      9,
      Paint()..color = colorScheme.tertiary,
    );
    canvas.drawCircle(
      point,
      9,
      Paint()
        ..color = colorScheme.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Slope readout.
    final tp = TextPainter(
      text: TextSpan(
        text: 'slope = ${m.toStringAsFixed(2)}',
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final pillRect = Rect.fromLTWH(
      size.width - tp.width - 24,
      8,
      tp.width + 16,
      tp.height + 8,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(999)),
      Paint()..color = colorScheme.surfaceContainerHigh,
    );
    tp.paint(canvas, Offset(pillRect.left + 8, pillRect.top + 4));
  }

  @override
  bool shouldRepaint(covariant _TangentPainter old) =>
      old.x != x || old.func != func || old.colorScheme != colorScheme;
}
