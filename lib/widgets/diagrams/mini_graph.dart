// lib/widgets/diagrams/mini_graph.dart
//
// A small, square static plot of one named function. Used in tap-graph
// question tiles. No labels, no axes labels — just the curve shape.

import 'package:flutter/material.dart';

import '../../models/micro_screen.dart';
import 'graph_helpers.dart';

class MiniGraph extends StatelessWidget {
  const MiniGraph({
    super.key,
    required this.func,
    this.curveColor,
    this.size = 96,
  });

  final GraphFunc func;
  final Color? curveColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MiniPainter(
          func: func,
          curveColor: curveColor ?? scheme.primary,
          axisColor: scheme.outline,
          gridColor: scheme.outlineVariant.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _MiniPainter extends CustomPainter {
  _MiniPainter({
    required this.func,
    required this.curveColor,
    required this.axisColor,
    required this.gridColor,
  });

  final GraphFunc func;
  final Color curveColor, axisColor, gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = defaultBounds(func);
    final t = GraphTransform(bounds: bounds, size: size, padding: 6);
    drawAxes(canvas, t, axis: axisColor, grid: gridColor, gridLines: false);
    drawFunction(canvas, t, func, curveColor, strokeWidth: 2.0);
  }

  @override
  bool shouldRepaint(covariant _MiniPainter old) =>
      old.func != func ||
      old.curveColor != curveColor ||
      old.axisColor != axisColor;
}
