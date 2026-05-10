// lib/data/unit_derivatives.dart
//
// Unit 2: Derivatives — the rate of change.
//
// This is the centrepiece. We follow 3Blue1Brown's pedagogy: build the
// concept image (slope of a moving tangent line) BEFORE introducing the
// notation. Mechanics rules (power, sum, etc.) come later.

import '../models/lesson.dart';
import '../models/micro_screen.dart';

final unitDerivatives = Unit(
  id: 'u-derivatives',
  title: 'Derivatives',
  tagline: 'How fast is it changing?',
  icon: 'd',
  lessons: [
    // ── L1: Slope as steepness ──────────────────────────────────────────
    Lesson(
      id: 'l-slope-intuition',
      title: 'Slope = steepness',
      subtitle: 'The first calculus question.',
      icon: '↗',
      xpReward: 14,
      screens: [
        HookScreen(
          itemId: 'slope-hook',
          title: 'Steeper means faster',
          subtitle:
              'The derivative is just slope — how fast the curve is rising.',
          diagram: DiagramKind.tangentSlider,
          durationMs: 6000,
        ),
        ExploreScreen(
          itemId: 'slope-explore',
          title: 'Drag the tangent',
          prompt:
              'Move the point along y = x². Watch the slope of the tangent line change.',
          diagram: DiagramKind.tangentSlider,
          sliderLabel: 'x position',
          minValue: -2.0,
          maxValue: 2.0,
          initialValue: 0.5,
        ),
        TapMatchScreen(
          itemId: 'slope-sign-match',
          prompt: 'Match each curve region to the slope sign.',
          pairs: [
            MatchPair(left: 'Going up', right: 'positive'),
            MatchPair(left: 'Going down', right: 'negative'),
            MatchPair(left: 'Flat (peak/valley)', right: 'zero'),
            MatchPair(left: 'Vertical wall', right: 'undefined'),
          ],
        ),
        TapGraphScreen(
          itemId: 'slope-which-zero',
          prompt: 'On which graph is the slope zero AT x = 0?',
          options: [
            GraphFunc.linearPos,
            GraphFunc.parabolaUp,
            GraphFunc.cubic,
            GraphFunc.exp,
          ],
          correctIndex: 1,
          solutionHint:
              'The bottom of the parabola is flat. y = x² has slope 0 at x = 0.',
        ),
        EstimateScreen(
          itemId: 'slope-estimate-line',
          prompt: 'Estimate the slope of y = x at any point.',
          estimateKind: EstimateKind.slopeAtPoint,
          func: GraphFunc.linearPos,
          parameter: 1.0,
          correctValue: 1.0,
          minValue: -3.0,
          maxValue: 3.0,
          tolerance: 0.2,
          solutionHint: 'A line of slope 1 has slope 1 everywhere.',
        ),
        SummaryScreen(
          itemId: 'slope-summary',
          title: 'Slope = derivative',
          takeaway:
              'The derivative at a point is the slope of the tangent line there. Positive going up, negative going down.',
        ),
      ],
    ),

    // ── L2: From secant to tangent ──────────────────────────────────────
    Lesson(
      id: 'l-secant-tangent',
      title: 'Secant → Tangent',
      subtitle: 'The limit definition, geometrically.',
      icon: '➝',
      xpReward: 16,
      screens: [
        HookScreen(
          itemId: 'secant-hook',
          title: 'Squeeze h to zero',
          subtitle:
              'A secant becomes a tangent as the two points merge. That\'s the derivative.',
          diagram: DiagramKind.secantToTangent,
          durationMs: 7000,
        ),
        ExploreScreen(
          itemId: 'secant-explore',
          title: 'Shrink the gap',
          prompt:
              'Drag the slider to shrink h. The secant line rotates toward the tangent.',
          diagram: DiagramKind.secantToTangent,
          sliderLabel: 'gap (h)',
          minValue: 0.05,
          maxValue: 1.5,
          initialValue: 1.0,
        ),
        FillBlankScreen(
          itemId: 'limit-def',
          prompt: 'Complete the limit definition of the derivative.',
          beforeBlank: "f'(x) = lim_{h→0} ",
          afterBlank: '',
          options: [
            '[f(x+h) − f(x)] / h',
            'f(x+h) − f(x)',
            '[f(x) − f(x−h)] / h',
            'h / [f(x+h) − f(x)]',
          ],
          correctIndex: 0,
          solutionHint:
              'Rise over run: change in f, divided by change in x (which is h).',
        ),
        McqScreen(
          itemId: 'derivative-meaning',
          prompt: 'What does f\'(2) = 5 mean, in plain English?',
          options: [
            McqOption(
              label: 'f equals 5 when x is 2',
              misconceptionNote: 'That would be f(2) = 5, not f\'(2).',
            ),
            McqOption(
              label: 'At x = 2, f is rising at 5 units per unit of x',
            ),
            McqOption(
              label: 'f reaches its maximum value of 5 at x = 2',
              misconceptionNote: 'A derivative of 5 is not zero — so x = 2 is not a max or min.',
            ),
            McqOption(
              label: 'The graph crosses 5 at x = 2',
              misconceptionNote: 'Slope, not height.',
            ),
          ],
          correctIndex: 1,
          solutionHint:
              "f'(a) is the rate of change of f at x = a. If it's 5, f is climbing 5 units of y for every 1 unit of x near there.",
        ),
        SummaryScreen(
          itemId: 'secant-summary',
          title: 'You\'ve invented calculus',
          takeaway:
              'A secant becomes a tangent when h shrinks to 0. That limit IS the derivative.',
          formula: "f'(x) = lim_{h→0} [f(x+h) − f(x)] / h",
        ),
      ],
    ),

    // ── L3: The power rule ─────────────────────────────────────────────
    Lesson(
      id: 'l-power-rule',
      title: 'The power rule',
      subtitle: 'Patterns make calculus quick.',
      icon: 'xⁿ',
      xpReward: 14,
      screens: [
        WorkedExampleScreen(
          itemId: 'power-warm',
          title: 'Three small examples',
          problem: 'Look at these. Notice the pattern.',
          steps: [
            ExampleStep(text: 'd/dx (x²) = 2x'),
            ExampleStep(text: 'd/dx (x³) = 3x²'),
            ExampleStep(text: 'd/dx (x⁴) = 4x³'),
            ExampleStep(text: "Each time: multiply by the exponent, then drop the exponent by 1."),
          ],
          result: 'Power Rule:  d/dx (xⁿ) = n · xⁿ⁻¹',
        ),
        FillBlankScreen(
          itemId: 'power-x5',
          prompt: 'Differentiate x⁵.',
          beforeBlank: 'd/dx (x⁵) = ',
          afterBlank: '',
          options: ['5x⁴', '5x⁵', 'x⁵/5', '4x⁵'],
          correctIndex: 0,
          solutionHint: 'Multiply by 5, drop exponent to 4.',
        ),
        FillBlankScreen(
          itemId: 'power-x10',
          prompt: 'Differentiate x¹⁰.',
          beforeBlank: 'd/dx (x¹⁰) = ',
          afterBlank: '',
          options: ['10x⁹', 'x¹⁰', '10x¹⁰', '9x¹⁰'],
          correctIndex: 0,
          solutionHint: 'Multiply by 10, exponent becomes 9.',
        ),
        TapMatchScreen(
          itemId: 'power-match',
          prompt: 'Match each function with its derivative.',
          pairs: [
            MatchPair(left: 'x⁶', right: '6x⁵'),
            MatchPair(left: 'x²', right: '2x'),
            MatchPair(left: 'x', right: '1'),
            MatchPair(left: 'x⁷', right: '7x⁶'),
          ],
        ),
        BuildExpressionScreen(
          itemId: 'power-build',
          prompt: 'Build the derivative of x⁸. Tap tiles in order.',
          tiles: ['8', 'x', '⁷', '⁸', '·', '7', '+', '⁶'],
          correctOrder: [0, 4, 1, 2],
          solutionHint: '8·x⁷ — coefficient first, then x, then exponent 7.',
        ),
        McqScreen(
          itemId: 'power-constant',
          prompt: 'What is d/dx (5)?',
          options: [
            McqOption(label: '5', misconceptionNote: 'A constant doesn\'t change with x — its rate of change is 0.'),
            McqOption(label: '0'),
            McqOption(label: '1', misconceptionNote: 'Derivative of x is 1, but a constant 5 has derivative 0.'),
            McqOption(label: '5x', misconceptionNote: '5x would be its INTEGRAL, not its derivative.'),
          ],
          correctIndex: 1,
          solutionHint:
              'Constants don\'t change. The slope of a horizontal line is 0.',
        ),
        SummaryScreen(
          itemId: 'power-summary',
          title: 'Power rule — locked in',
          takeaway:
              'For xⁿ: bring the exponent down as a coefficient, then subtract 1 from the exponent.',
          formula: 'd/dx (xⁿ) = n·xⁿ⁻¹',
        ),
      ],
    ),

    // ── L4: Sum and constant-multiple ──────────────────────────────────
    Lesson(
      id: 'l-sum-rule',
      title: 'Sums & constants',
      subtitle: 'Differentiate piece by piece.',
      icon: '+',
      xpReward: 12,
      screens: [
        WorkedExampleScreen(
          itemId: 'sum-rule-worked',
          title: 'Differentiate a sum',
          problem: 'Find d/dx (3x² + 5x − 7).',
          steps: [
            ExampleStep(text: 'Differentiate each term separately.'),
            ExampleStep(text: 'd/dx (3x²) = 3·2x = 6x'),
            ExampleStep(text: 'd/dx (5x) = 5'),
            ExampleStep(text: 'd/dx (−7) = 0'),
            ExampleStep(text: 'Add them up.'),
          ],
          result: 'd/dx (3x² + 5x − 7) = 6x + 5',
        ),
        FillBlankScreen(
          itemId: 'sum-rule-1',
          prompt: 'Differentiate 4x³ + 2x.',
          beforeBlank: 'd/dx = ',
          afterBlank: '',
          options: ['12x² + 2', '12x² + 2x', '4x² + 2', '3x² + 2'],
          correctIndex: 0,
          solutionHint: '4·3x² for the cube, 2·1 for the linear.',
        ),
        BuildExpressionScreen(
          itemId: 'sum-rule-build',
          prompt: 'Build the derivative of x³ − 2x.',
          tiles: ['3x²', 'x²', '−', '+', '2', 'x', '−2'],
          correctOrder: [0, 2, 4],
          solutionHint: '3x² minus 2 — drop the linear coefficient.',
        ),
        ReorderScreen(
          itemId: 'sum-rule-reorder',
          prompt: 'Re-order these steps to differentiate 5x⁴ − 3.',
          shuffledSteps: [
            'd/dx (5x⁴) = 5 · 4x³ = 20x³',
            'd/dx (−3) = 0',
            'Final: 20x³',
            'Differentiate each term separately',
          ],
          correctOrder: [3, 0, 1, 2],
          solutionHint:
              'Plan first, differentiate each term, drop the constant, combine.',
        ),
        SummaryScreen(
          itemId: 'sum-summary',
          title: 'Sums = piecewise differentiation',
          takeaway:
              'Differentiate term by term. Constants vanish. Coefficients stay along for the ride.',
          formula: 'd/dx [f + g] = f\' + g\'',
        ),
      ],
    ),

    // ── L5: Special functions (e^x, sin, cos) ──────────────────────────
    Lesson(
      id: 'l-special-derivs',
      title: 'Famous derivatives',
      subtitle: 'eˣ, sin, cos — patterns to memorise.',
      icon: '✦',
      xpReward: 14,
      screens: [
        HookScreen(
          itemId: 'special-derivs-hook',
          title: 'Some functions are their own thing',
          subtitle:
              'Here are three derivatives you should know on sight.',
          diagram: DiagramKind.derivativeOfPlot,
          durationMs: 5500,
        ),
        TapMatchScreen(
          itemId: 'special-match',
          prompt: 'Match each function to its derivative.',
          pairs: [
            MatchPair(left: 'eˣ', right: 'eˣ'),
            MatchPair(left: 'sin x', right: 'cos x'),
            MatchPair(left: 'cos x', right: '−sin x'),
            MatchPair(left: 'ln x', right: '1/x'),
          ],
        ),
        FillBlankScreen(
          itemId: 'derivative-sin',
          prompt: "Differentiate sin x.",
          beforeBlank: 'd/dx (sin x) = ',
          afterBlank: '',
          options: ['cos x', '−cos x', '−sin x', 'tan x'],
          correctIndex: 0,
          solutionHint: 'Sin\'s derivative is cos. Cos\'s gets the minus sign.',
        ),
        FillBlankScreen(
          itemId: 'derivative-cos',
          prompt: 'Differentiate cos x.',
          beforeBlank: 'd/dx (cos x) = ',
          afterBlank: '',
          options: ['sin x', '−sin x', 'cos x', '−cos x'],
          correctIndex: 1,
          solutionHint: 'Cosine flips its sign when differentiated. Remember the minus.',
        ),
        McqScreen(
          itemId: 'special-ex',
          prompt: 'What\'s special about d/dx (eˣ)?',
          options: [
            McqOption(label: 'It equals eˣ — eˣ is its own derivative'),
            McqOption(label: 'It equals 1', misconceptionNote: 'No — eˣ doesn\'t become a constant.'),
            McqOption(label: 'It equals x·eˣ', misconceptionNote: 'That would be the chain rule on something else.'),
            McqOption(label: 'It equals ln x', misconceptionNote: '1/x is the derivative of ln x, not eˣ.'),
          ],
          correctIndex: 0,
          solutionHint:
              'eˣ is the unique function that equals its own derivative — that\'s why it\'s everywhere in physics.',
        ),
        SummaryScreen(
          itemId: 'special-summary',
          title: 'Three to memorise',
          takeaway: 'eˣ → eˣ.   sin → cos.   cos → −sin.',
          formula: 'd/dx (eˣ) = eˣ,  d/dx (sin x) = cos x,  d/dx (cos x) = −sin x',
        ),
      ],
    ),
  ],
);
