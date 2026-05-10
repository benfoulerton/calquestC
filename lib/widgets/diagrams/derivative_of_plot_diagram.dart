// lib/widgets/diagrams/derivative_of_plot_diagram.dart
//
// Two stacked plots: the function and its derivative. A traveller dot
// connects them — at each x, the y-value on the lower plot equals the
// slope of the upper plot at that x. Builds the f → f' concept image.

import 'package:flutter/material.dart';

import 'graph_helpers.dart';
import '../../models/micro_screen.dart';

class DerivativeOfPlotDiagram extends StatefulWidget {
  const DerivativeOfPlotDiagram({
    super.key,
    this.controlledX,
    this.func = GraphFunc.parabolaUp,
    this.autoAnimate = true,
  });

  final double? controlledX;
  final GraphFunc func;
  final bool autoAnimate;

  @override
  State<DerivativeOfPlotDiagram> createState() =>
      _DerivativeOfPlotDiagramState();
}

class _DerivativeOfPlotDiagramState extends State<DerivativeOfPlotDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  double _x = -1.5;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    if (widget.autoAnimate && widget.controlledX == null) {
      _ac.addListener(() {
        setState(() => _x = -2 + _ac.value * 4);
      });
      _ac.repeat(reverse: true);
    } else if (widget.controlledX != null) {
      _x = widget.controlledX!;
    }
  }

  @override
  void didUpdateWidget(covariant DerivativeOfPlotDiagram old) {
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
      painter: _DerivPlotPainter(
        x: _x,
        func: widget.func,
        colorScheme: Theme.of(context).colorScheme,
      ),
    );
  }
}

class _DerivPlotPainter extends CustomPainter {
  _DerivPlotPainter({
    required this.x,
    required this.func,
    required this.colorScheme,
  });

  final double x;
  final GraphFunc func;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    // Two stacked plots: top half is f, bottom half is f'.
    final topRect = Rect.fromLTWH(0, 0, size.width, size.height / 2 - 4);
    final botRect = Rect.fromLTWH(0, size.height / 2 + 4,
        size.width, size.height / 2 - 4);

    final fBounds = MathBounds(xMin: -2, xMax: 2, yMin: -1, yMax: 4);
    final dfBounds = MathBounds(xMin: -2, xMax: 2, yMin: -5, yMax: 5);

    final fT = GraphTransform(bounds: fBounds, size: topRect.size);
    final dfT = GraphTransform(bounds: dfBounds, size: botRect.size);

    canvas.save();
    canvas.translate(topRect.left, topRect.top);
    drawAxes(canvas, fT,
        axis: colorScheme.outline,
        grid: colorScheme.outlineVariant.withOpacity(0.3));
    drawFunction(canvas, fT, func, colorScheme.primary);

    // Tangent dot in top.
    final y = evalGraph(func, x);
    final m = slopeAt(func, x);
    final dx = 0.6;
    final tangentP1 = fT.toPixel(x - dx, y - m * dx);
    final tangentP2 = fT.toPixel(x + dx, y + m * dx);
    canvas.drawLine(
      tangentP1,
      tangentP2,
      Paint()
        ..color = colorScheme.tertiary
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(fT.toPixel(x, y), 7, Paint()..color = colorScheme.tertiary);

    // Top label.
    _label(canvas, 'f(x)', colorScheme.primary, 8, 8);
    canvas.restore();

    canvas.save();
    canvas.translate(botRect.left, botRect.top);
    drawAxes(canvas, dfT,
        axis: colorScheme.outline,
        grid: colorScheme.outlineVariant.withOpacity(0.3));

    // Plot derivative as a custom path (we have slopeAt for our funcs).
    final paint = Paint()
      ..color = colorScheme.tertiary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    bool started = false;
    const samples = 200;
    for (var i = 0; i <= samples; i++) {
      final xi = dfBounds.xMin + i * dfBounds.width / samples;
      final yi = slopeAt(func, xi);
      if (yi.isNaN || yi.isInfinite) {
        started = false;
        continue;
      }
      final clampedY = yi.clamp(dfBounds.yMin - 1, dfBounds.yMax + 1).toDouble();
      final p = dfT.toPixel(xi, clampedY);
      if (!started) {
        path.moveTo(p.dx, p.dy);
        started = true;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);

    // Marker dot on f' showing the matching y = slope.
    canvas.drawCircle(
      dfT.toPixel(x, m),
      7,
      Paint()..color = colorScheme.tertiary,
    );

    _label(canvas, "f'(x)", colorScheme.tertiary, 8, 8);
    canvas.restore();
  }

  void _label(Canvas canvas, String text, Color color, double dx, double dy) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _DerivPlotPainter old) =>
      old.x != x || old.func != func || old.colorScheme != colorScheme;
}
