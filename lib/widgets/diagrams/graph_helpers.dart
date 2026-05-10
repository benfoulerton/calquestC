// lib/widgets/diagrams/graph_helpers.dart
//
// Shared utilities for math-coord-to-pixel conversion, function evaluation,
// and basic graph rendering. All diagrams build on this.

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../models/micro_screen.dart';

/// A bounding box for math coordinates: [xMin, xMax] × [yMin, yMax].
class MathBounds {
  const MathBounds({
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  final double xMin, xMax, yMin, yMax;

  double get width => xMax - xMin;
  double get height => yMax - yMin;
}

/// Linear conversion from math (x, y) to pixel-space (px, py) inside a Size.
class GraphTransform {
  GraphTransform({required this.bounds, required this.size, this.padding = 16});
  final MathBounds bounds;
  final Size size;
  final double padding;

  double get _w => size.width - padding * 2;
  double get _h => size.height - padding * 2;

  Offset toPixel(double x, double y) {
    final px = padding + (x - bounds.xMin) / bounds.width * _w;
    final py = padding + (bounds.yMax - y) / bounds.height * _h;
    return Offset(px, py);
  }

  /// Inverse: pixel back to math x.
  double toMathX(double px) =>
      bounds.xMin + (px - padding) / _w * bounds.width;
}

/// Evaluate one of the named graph functions at x.
double evalGraph(GraphFunc f, double x) {
  switch (f) {
    case GraphFunc.linearPos:
      return x;
    case GraphFunc.linearNeg:
      return -x;
    case GraphFunc.parabolaUp:
      return x * x;
    case GraphFunc.parabolaDown:
      return -(x * x);
    case GraphFunc.cubic:
      return x * x * x;
    case GraphFunc.sine:
      return math.sin(x);
    case GraphFunc.cosine:
      return math.cos(x);
    case GraphFunc.exp:
      return math.exp(x);
    case GraphFunc.reciprocal:
      // Avoid the singularity by returning NaN near 0.
      if (x.abs() < 0.05) return double.nan;
      return 1 / x;
    case GraphFunc.absolute:
      return x.abs();
    case GraphFunc.sqrt:
      return x < 0 ? double.nan : math.sqrt(x);
    case GraphFunc.constant:
      return 1;
    case GraphFunc.step:
      return x < 0 ? 0 : 1;
    case GraphFunc.logistic:
      return 1.0 / (1.0 + math.exp(-x));
    case GraphFunc.bell:
      return math.exp(-x * x);
  }
}

/// A nice display label for a function.
String labelGraph(GraphFunc f) {
  switch (f) {
    case GraphFunc.linearPos: return 'y = x';
    case GraphFunc.linearNeg: return 'y = -x';
    case GraphFunc.parabolaUp: return 'y = x²';
    case GraphFunc.parabolaDown: return 'y = -x²';
    case GraphFunc.cubic: return 'y = x³';
    case GraphFunc.sine: return 'y = sin x';
    case GraphFunc.cosine: return 'y = cos x';
    case GraphFunc.exp: return 'y = eˣ';
    case GraphFunc.reciprocal: return 'y = 1/x';
    case GraphFunc.absolute: return 'y = |x|';
    case GraphFunc.sqrt: return 'y = √x';
    case GraphFunc.constant: return 'y = 1';
    case GraphFunc.step: return 'step';
    case GraphFunc.logistic: return 'sigmoid';
    case GraphFunc.bell: return 'e^(-x²)';
  }
}

/// A reasonable default math-bounds for a function.
MathBounds defaultBounds(GraphFunc f) {
  switch (f) {
    case GraphFunc.exp:
      return const MathBounds(xMin: -2, xMax: 2, yMin: -1, yMax: 7);
    case GraphFunc.reciprocal:
      return const MathBounds(xMin: -3, xMax: 3, yMin: -3, yMax: 3);
    case GraphFunc.sqrt:
      return const MathBounds(xMin: -1, xMax: 4, yMin: -1, yMax: 3);
    case GraphFunc.sine:
    case GraphFunc.cosine:
      return const MathBounds(xMin: -math.pi, xMax: math.pi, yMin: -1.5, yMax: 1.5);
    case GraphFunc.cubic:
      return const MathBounds(xMin: -2, xMax: 2, yMin: -8, yMax: 8);
    case GraphFunc.constant:
      return const MathBounds(xMin: -2, xMax: 2, yMin: -1, yMax: 2);
    case GraphFunc.step:
      return const MathBounds(xMin: -2, xMax: 2, yMin: -0.5, yMax: 1.5);
    default:
      return const MathBounds(xMin: -3, xMax: 3, yMin: -3, yMax: 5);
  }
}

/// Slope (analytic derivative) of a named function at x.
double slopeAt(GraphFunc f, double x) {
  switch (f) {
    case GraphFunc.linearPos: return 1;
    case GraphFunc.linearNeg: return -1;
    case GraphFunc.parabolaUp: return 2 * x;
    case GraphFunc.parabolaDown: return -2 * x;
    case GraphFunc.cubic: return 3 * x * x;
    case GraphFunc.sine: return math.cos(x);
    case GraphFunc.cosine: return -math.sin(x);
    case GraphFunc.exp: return math.exp(x);
    case GraphFunc.reciprocal: return -1 / (x * x);
    case GraphFunc.absolute: return x >= 0 ? 1 : -1;
    case GraphFunc.sqrt: return x <= 0 ? double.nan : 1 / (2 * math.sqrt(x));
    case GraphFunc.constant: return 0;
    case GraphFunc.step: return 0;
    case GraphFunc.logistic:
      final s = 1 / (1 + math.exp(-x));
      return s * (1 - s);
    case GraphFunc.bell: return -2 * x * math.exp(-x * x);
  }
}

/// Definite integral of a named function from a to b (used for area
/// estimates). Computed via Simpson's rule for accuracy.
double integralFromTo(GraphFunc f, double a, double b, {int n = 200}) {
  if (n.isOdd) n++;
  final h = (b - a) / n;
  var sum = evalGraph(f, a) + evalGraph(f, b);
  for (var i = 1; i < n; i++) {
    final x = a + i * h;
    final y = evalGraph(f, x);
    if (y.isNaN) continue;
    sum += (i.isOdd ? 4 : 2) * y;
  }
  return (h / 3) * sum;
}

// ============================================================================
// Painter helpers
// ============================================================================

/// Draws a clean axis cross with subtle grid lines.
void drawAxes(
  Canvas canvas,
  GraphTransform t, {
  required Color axis,
  required Color grid,
  double strokeWidth = 1.0,
  bool gridLines = true,
}) {
  final gridPaint = Paint()
    ..color = grid
    ..strokeWidth = 1;
  final axisPaint = Paint()
    ..color = axis
    ..strokeWidth = strokeWidth;

  // Grid lines at integer x values inside bounds.
  if (gridLines) {
    final xMinInt = t.bounds.xMin.ceil();
    final xMaxInt = t.bounds.xMax.floor();
    for (var x = xMinInt; x <= xMaxInt; x++) {
      if (x == 0) continue;
      final p1 = t.toPixel(x.toDouble(), t.bounds.yMin);
      final p2 = t.toPixel(x.toDouble(), t.bounds.yMax);
      canvas.drawLine(p1, p2, gridPaint);
    }
    final yMinInt = t.bounds.yMin.ceil();
    final yMaxInt = t.bounds.yMax.floor();
    for (var y = yMinInt; y <= yMaxInt; y++) {
      if (y == 0) continue;
      final p1 = t.toPixel(t.bounds.xMin, y.toDouble());
      final p2 = t.toPixel(t.bounds.xMax, y.toDouble());
      canvas.drawLine(p1, p2, gridPaint);
    }
  }

  // Axes through origin (only if origin is in view).
  if (t.bounds.yMin < 0 && t.bounds.yMax > 0) {
    final p1 = t.toPixel(t.bounds.xMin, 0);
    final p2 = t.toPixel(t.bounds.xMax, 0);
    canvas.drawLine(p1, p2, axisPaint);
  }
  if (t.bounds.xMin < 0 && t.bounds.xMax > 0) {
    final p1 = t.toPixel(0, t.bounds.yMin);
    final p2 = t.toPixel(0, t.bounds.yMax);
    canvas.drawLine(p1, p2, axisPaint);
  }
}

/// Plot a function on the canvas as a smooth path.
void drawFunction(
  Canvas canvas,
  GraphTransform t,
  GraphFunc f,
  Color color, {
  double strokeWidth = 2.5,
  int samples = 200,
}) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final path = Path();
  bool started = false;
  for (var i = 0; i <= samples; i++) {
    final x = t.bounds.xMin + i * t.bounds.width / samples;
    final y = evalGraph(f, x);
    if (y.isNaN || y.isInfinite) {
      started = false;
      continue;
    }
    final clampedY = y.clamp(t.bounds.yMin - 1, t.bounds.yMax + 1).toDouble();
    final p = t.toPixel(x, clampedY);
    if (!started) {
      path.moveTo(p.dx, p.dy);
      started = true;
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  canvas.drawPath(path, paint);
}
