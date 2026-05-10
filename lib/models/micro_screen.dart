// lib/models/micro_screen.dart
//
// The new content model: a Lesson is an ordered list of MicroScreens.
// Each MicroScreen is one of several typed kinds — a visual hook, an
// interactive question, a summary card. The Runner steps through them
// one at a time and records correctness for FSRS-lite review.

import 'package:flutter/material.dart';

/// What kind of micro-screen it is. Drives which widget gets rendered.
enum ScreenKind {
  /// Pure animation, no input. "Watch what happens."
  visualHook,

  /// Drag a slider; observe a diagram update. No wrong answer.
  exploreSlider,

  /// Step-through worked example: tap to advance through highlighted steps.
  workedExample,

  /// Tap-to-match — pair items from left column to right.
  tapMatch,

  /// Fill in the blank in an equation by tapping a token from a list.
  fillBlank,

  /// Show 3-4 graphs, tap the one matching a description.
  tapGraph,

  /// Drag a slider to estimate (slope, area). Tolerance band scoring.
  estimate,

  /// Tap pieces in order to assemble an expression.
  buildExpression,

  /// Re-order shuffled steps of a derivation.
  reorderSteps,

  /// 4-option multiple-choice. Final summative check.
  multipleChoice,

  /// "Today you learned" recap. No input.
  summary,
}

/// Base class for all micro-screens. Each kind carries its own typed payload
/// in a subclass so the runner can `switch` on `kind` and access the right
/// fields.
sealed class MicroScreen {
  const MicroScreen({required this.kind});
  final ScreenKind kind;

  /// True if this screen requires correctness — i.e. it's a question. Hooks,
  /// explores, worked examples, and summaries don't.
  bool get isQuestion => switch (kind) {
        ScreenKind.tapMatch ||
        ScreenKind.fillBlank ||
        ScreenKind.tapGraph ||
        ScreenKind.estimate ||
        ScreenKind.buildExpression ||
        ScreenKind.reorderSteps ||
        ScreenKind.multipleChoice =>
          true,
        _ => false,
      };

  /// A short stable id used for spaced-repetition tracking. Concept-level.
  /// Usually set by the lesson author to group items by skill (e.g. "deriv-power").
  String get itemId;
}

// ============================================================================
// VISUAL HOOK — pure animation, no input
// ============================================================================

/// Identifies which built-in animated diagram to play for the hook.
enum DiagramKind {
  tangentSlider,    // drag a tangent line along a curve
  riemannSum,       // adjust n, watch rectangles fill the area
  limitShrink,      // ε–δ band shrinks
  functionMachine,  // input → box → output
  secantToTangent,  // animated h → 0
  areaAccumulator,  // odometer-style accumulation
  derivativeOfPlot, // f and f' shown side-by-side
  chainNested,      // nested transformations
}

/// Pure-animation screen. The diagram plays automatically; user just
/// watches. Auto-advance after duration, or button "Got it".
class HookScreen extends MicroScreen {
  const HookScreen({
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.diagram,
    this.durationMs = 6000,
  }) : super(kind: ScreenKind.visualHook);

  @override
  final String itemId;
  final String title;
  final String subtitle;
  final DiagramKind diagram;
  final int durationMs;
}

// ============================================================================
// EXPLORE SLIDER — interactive diagram, no wrong answer
// ============================================================================

/// User drags a slider and watches a diagram react. There's no scoring;
/// it's a "play with this" screen meant to build intuition.
class ExploreScreen extends MicroScreen {
  const ExploreScreen({
    required this.itemId,
    required this.title,
    required this.prompt,
    required this.diagram,
    required this.sliderLabel,
    this.minValue = 0,
    this.maxValue = 1,
    this.initialValue = 0.5,
  }) : super(kind: ScreenKind.exploreSlider);

  @override
  final String itemId;
  final String title;
  final String prompt;
  final DiagramKind diagram;
  final String sliderLabel;
  final double minValue;
  final double maxValue;
  final double initialValue;
}

// ============================================================================
// WORKED EXAMPLE — tap-through stepped reveal
// ============================================================================

/// One step of a worked example.
class ExampleStep {
  const ExampleStep({required this.text, this.highlight});
  final String text;
  /// Optional: which earlier step's text fragment is being transformed.
  final String? highlight;
}

class WorkedExampleScreen extends MicroScreen {
  const WorkedExampleScreen({
    required this.itemId,
    required this.title,
    required this.problem,
    required this.steps,
    required this.result,
  }) : super(kind: ScreenKind.workedExample);

  @override
  final String itemId;
  final String title;
  final String problem;
  final List<ExampleStep> steps;
  final String result;
}

// ============================================================================
// TAP-MATCH — pair left items with right items
// ============================================================================

class MatchPair {
  const MatchPair({required this.left, required this.right});
  final String left;
  final String right;
}

class TapMatchScreen extends MicroScreen {
  const TapMatchScreen({
    required this.itemId,
    required this.prompt,
    required this.pairs,
  }) : super(kind: ScreenKind.tapMatch);

  @override
  final String itemId;
  final String prompt;
  final List<MatchPair> pairs;
}

// ============================================================================
// FILL-BLANK — choose token to drop into a blank
// ============================================================================

class FillBlankScreen extends MicroScreen {
  const FillBlankScreen({
    required this.itemId,
    required this.prompt,
    required this.beforeBlank,
    required this.afterBlank,
    required this.options,
    required this.correctIndex,
    this.solutionHint,
  }) : super(kind: ScreenKind.fillBlank);

  @override
  final String itemId;
  final String prompt;
  final String beforeBlank;
  final String afterBlank;
  final List<String> options;
  final int correctIndex;
  final String? solutionHint;
}

// ============================================================================
// TAP-GRAPH — pick the right graph from 3-4 options
// ============================================================================

/// A function specifier the painter can plot. We use named built-ins rather
/// than parsing strings — keeps the renderer simple and fast.
enum GraphFunc {
  linearPos,        // y = x
  linearNeg,        // y = -x
  parabolaUp,       // y = x²
  parabolaDown,     // y = -x²
  cubic,            // y = x³
  sine,             // y = sin(x)
  cosine,           // y = cos(x)
  exp,              // y = e^x
  reciprocal,       // y = 1/x
  absolute,         // y = |x|
  sqrt,             // y = √x
  constant,         // y = 1
  step,             // step function at 0
  logistic,         // sigmoid
  bell,             // y = e^{-x²}
}

class TapGraphScreen extends MicroScreen {
  const TapGraphScreen({
    required this.itemId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.solutionHint,
  }) : super(kind: ScreenKind.tapGraph);

  @override
  final String itemId;
  final String prompt;
  final List<GraphFunc> options;
  final int correctIndex;
  final String? solutionHint;
}

// ============================================================================
// ESTIMATE — drag a slider to estimate, tolerance band scoring
// ============================================================================

enum EstimateKind {
  slopeAtPoint,
  areaUnderCurve,
  limitValue,
  derivativeAtPoint,
}

class EstimateScreen extends MicroScreen {
  const EstimateScreen({
    required this.itemId,
    required this.prompt,
    required this.estimateKind,
    required this.func,
    required this.parameter, // x-coord, etc., depending on kind
    required this.correctValue,
    required this.minValue,
    required this.maxValue,
    this.tolerance = 0.15, // ± 15% of correctValue range
    this.solutionHint,
  }) : super(kind: ScreenKind.estimate);

  @override
  final String itemId;
  final String prompt;
  final EstimateKind estimateKind;
  final GraphFunc func;
  final double parameter;
  final double correctValue;
  final double minValue;
  final double maxValue;
  final double tolerance;
  final String? solutionHint;
}

// ============================================================================
// BUILD-EXPRESSION — tap pieces in order to assemble
// ============================================================================

class BuildExpressionScreen extends MicroScreen {
  const BuildExpressionScreen({
    required this.itemId,
    required this.prompt,
    required this.tiles,
    required this.correctOrder,
    this.solutionHint,
  }) : super(kind: ScreenKind.buildExpression);

  @override
  final String itemId;
  final String prompt;

  /// The list of tile labels available. Tiles include distractors. Indices
  /// in [correctOrder] refer to indices in this list.
  final List<String> tiles;

  /// The tile indices in the correct order.
  final List<int> correctOrder;
  final String? solutionHint;
}

// ============================================================================
// REORDER STEPS — drag/tap to put steps in the right order
// ============================================================================

class ReorderScreen extends MicroScreen {
  const ReorderScreen({
    required this.itemId,
    required this.prompt,
    required this.shuffledSteps,
    required this.correctOrder,
    this.solutionHint,
  }) : super(kind: ScreenKind.reorderSteps);

  @override
  final String itemId;
  final String prompt;

  /// Steps as they're presented (shuffled). The runtime will shuffle further
  /// at runtime so the same lesson re-played has different starting orders.
  final List<String> shuffledSteps;

  /// The correct ordering: indices into [shuffledSteps].
  final List<int> correctOrder;
  final String? solutionHint;
}

// ============================================================================
// MULTIPLE CHOICE — 4 options, one correct, distractors target misconceptions
// ============================================================================

class McqOption {
  const McqOption({required this.label, this.misconceptionNote});
  final String label;
  /// If user picks this wrong option, show this targeted hint.
  final String? misconceptionNote;
}

class McqScreen extends MicroScreen {
  const McqScreen({
    required this.itemId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.solutionHint,
  }) : super(kind: ScreenKind.multipleChoice);

  @override
  final String itemId;
  final String prompt;
  final List<McqOption> options;
  final int correctIndex;
  final String? solutionHint;
}

// ============================================================================
// SUMMARY — recap card at end of lesson
// ============================================================================

class SummaryScreen extends MicroScreen {
  const SummaryScreen({
    required this.itemId,
    required this.title,
    required this.takeaway,
    this.formula,
  }) : super(kind: ScreenKind.summary);

  @override
  final String itemId;
  final String title;
  final String takeaway;
  /// Optional one-line formula or notation summary.
  final String? formula;
}
