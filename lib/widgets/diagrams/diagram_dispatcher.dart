// lib/widgets/diagrams/diagram_dispatcher.dart
//
// Given a DiagramKind plus optional control parameters, returns the
// appropriate diagram widget. Used by both HookScreen (auto-animate) and
// ExploreScreen (slider-driven).

import 'package:flutter/material.dart';

import '../../models/micro_screen.dart';
import 'area_accumulator_diagram.dart';
import 'derivative_of_plot_diagram.dart';
import 'function_machine_diagram.dart';
import 'limit_shrink_diagram.dart';
import 'riemann_sum_diagram.dart';
import 'secant_to_tangent_diagram.dart';
import 'tangent_slider_diagram.dart';

class DiagramView extends StatelessWidget {
  const DiagramView({
    super.key,
    required this.kind,
    this.controlValue,
    this.autoAnimate = false,
  });

  final DiagramKind kind;

  /// External control: x-position, h-value, n-value, etc., depending on kind.
  /// Null means use the diagram's internal animation or default.
  final double? controlValue;

  final bool autoAnimate;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case DiagramKind.tangentSlider:
        return TangentSliderDiagram(
          controlledX: controlValue,
          autoAnimate: autoAnimate,
        );
      case DiagramKind.riemannSum:
        return RiemannSumDiagram(
          controlledN: controlValue,
          autoAnimate: autoAnimate,
        );
      case DiagramKind.limitShrink:
        return LimitShrinkDiagram(
          controlledX: controlValue,
          autoAnimate: autoAnimate,
        );
      case DiagramKind.functionMachine:
        return const FunctionMachineDiagram(autoAnimate: true);
      case DiagramKind.secantToTangent:
        return SecantToTangentDiagram(
          controlledH: controlValue,
          autoAnimate: autoAnimate,
        );
      case DiagramKind.areaAccumulator:
        return AreaAccumulatorDiagram(
          controlledX: controlValue,
          autoAnimate: autoAnimate,
        );
      case DiagramKind.derivativeOfPlot:
        return DerivativeOfPlotDiagram(
          controlledX: controlValue,
          autoAnimate: autoAnimate,
        );
      case DiagramKind.chainNested:
        // Not yet implemented as a custom painter — fall back to function machine.
        return const FunctionMachineDiagram(autoAnimate: true);
    }
  }
}
