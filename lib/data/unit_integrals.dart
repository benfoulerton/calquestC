// lib/data/unit_integrals.dart
//
// Unit 3: Integrals — accumulation, area, the FTC.
//
// We follow the brief: integration as ACCUMULATION first (Riemann sum
// slider, area-accumulator odometer), and only then surface the FTC as a
// "discovered" relationship between rate and accumulation.

import '../models/lesson.dart';
import '../models/micro_screen.dart';

final unitIntegrals = Unit(
  id: 'u-integrals',
  title: 'Integrals',
  tagline: 'Adding up tiny pieces.',
  icon: '∫',
  lessons: [
    // ── L1: Area as accumulation ───────────────────────────────────────
    Lesson(
      id: 'l-riemann-intro',
      title: 'Area under a curve',
      subtitle: 'Sum lots of tiny rectangles.',
      icon: '▤',
      xpReward: 14,
      screens: [
        HookScreen(
          itemId: 'riemann-hook',
          title: 'Many rectangles. Less error.',
          subtitle:
              'Add up rectangles under a curve. The thinner they are, the truer the area.',
          diagram: DiagramKind.riemannSum,
          durationMs: 6500,
        ),
        ExploreScreen(
          itemId: 'riemann-explore',
          title: 'Slide n higher',
          prompt:
              'Drag the slider. With more rectangles, the gap shrinks toward the actual area.',
          diagram: DiagramKind.riemannSum,
          sliderLabel: 'rectangles (n)',
          minValue: 2,
          maxValue: 40,
          initialValue: 4,
        ),
        TapGraphScreen(
          itemId: 'integral-bigger-area',
          prompt:
              'Which graph would have the LARGEST area under it from x = 0 to x = 1?',
          options: [
            GraphFunc.constant,
            GraphFunc.parabolaUp,
            GraphFunc.sqrt,
            GraphFunc.linearPos,
          ],
          correctIndex: 0,
          solutionHint:
              'On [0, 1], the constant 1 is the highest function — biggest rectangle.',
        ),
        EstimateScreen(
          itemId: 'integral-area-line',
          prompt:
              'Estimate the area under y = x from x = 0 to x = 2. (It\'s a triangle.)',
          estimateKind: EstimateKind.areaUnderCurve,
          func: GraphFunc.linearPos,
          parameter: 2.0,
          correctValue: 2.0,
          minValue: 0.0,
          maxValue: 4.0,
          tolerance: 0.2,
          solutionHint:
              'Triangle of base 2 and height 2 — area = ½·2·2 = 2.',
        ),
        SummaryScreen(
          itemId: 'riemann-summary',
          title: 'Area = sum of pieces',
          takeaway:
              'A definite integral is just lots of skinny rectangles, added up. The notation comes next.',
          formula: '∫ₐᵇ f(x) dx ≈ Σ f(xᵢ) · Δx',
        ),
      ],
    ),

    // ── L2: The integral notation ──────────────────────────────────────
    Lesson(
      id: 'l-integral-notation',
      title: 'Integral notation',
      subtitle: 'The tall S means "sum".',
      icon: '∫',
      xpReward: 12,
      screens: [
        WorkedExampleScreen(
          itemId: 'notation-walk',
          title: 'Reading ∫ₐᵇ f(x) dx',
          problem: 'Decode each piece of integral notation.',
          steps: [
            ExampleStep(text: '∫ — the long S, "sum".'),
            ExampleStep(text: 'a — start of the interval.'),
            ExampleStep(text: 'b — end of the interval.'),
            ExampleStep(text: 'f(x) — what we\'re measuring.'),
            ExampleStep(text: 'dx — an infinitesimally thin slice of x.'),
          ],
          result: '∫ₐᵇ f(x) dx = "sum f(x) along x, from a to b"',
        ),
        TapMatchScreen(
          itemId: 'integral-parts',
          prompt: 'Match each symbol in ∫₀² x dx to its meaning.',
          pairs: [
            MatchPair(left: '∫', right: 'sum'),
            MatchPair(left: '0', right: 'start'),
            MatchPair(left: '2', right: 'end'),
            MatchPair(left: 'dx', right: 'tiny slice'),
          ],
        ),
        FillBlankScreen(
          itemId: 'integral-constant',
          prompt: 'Compute ∫₀³ 1 dx (the area of a 3×1 rectangle).',
          beforeBlank: '∫₀³ 1 dx = ',
          afterBlank: '',
          options: ['1', '3', '4', '0'],
          correctIndex: 1,
          solutionHint:
              'You\'re adding the constant 1 across an interval of length 3.',
        ),
        SummaryScreen(
          itemId: 'notation-summary',
          title: 'You can read integrals now',
          takeaway:
              'Every integral is just "sum this thing across this range".',
        ),
      ],
    ),

    // ── L3: The Fundamental Theorem ─────────────────────────────────────
    Lesson(
      id: 'l-ftc',
      title: 'The Fundamental Theorem',
      subtitle: 'Derivatives undo integrals.',
      icon: '↺',
      xpReward: 16,
      screens: [
        HookScreen(
          itemId: 'ftc-hook',
          title: 'They\'re inverses',
          subtitle:
              'Differentiation and integration are opposite operations.',
          diagram: DiagramKind.areaAccumulator,
          durationMs: 6000,
        ),
        WorkedExampleScreen(
          itemId: 'ftc-worked',
          title: 'Compute ∫₀² 2x dx using the FTC',
          problem: '∫₀² 2x dx = ?',
          steps: [
            ExampleStep(text: 'Find an antiderivative of 2x. That\'s x².'),
            ExampleStep(text: 'Evaluate at the upper limit: (2)² = 4.'),
            ExampleStep(text: 'Evaluate at the lower limit: (0)² = 0.'),
            ExampleStep(text: 'Subtract: 4 − 0 = 4.'),
          ],
          result: '∫₀² 2x dx = 4',
        ),
        FillBlankScreen(
          itemId: 'ftc-x2',
          prompt: 'Compute ∫₀¹ 2x dx.',
          beforeBlank: '∫₀¹ 2x dx = ',
          afterBlank: '',
          options: ['1', '2', '1/2', '0'],
          correctIndex: 0,
          solutionHint: 'Antiderivative is x². At 1 it\'s 1. At 0 it\'s 0. Difference: 1.',
        ),
        ReorderScreen(
          itemId: 'ftc-reorder',
          prompt: 'Re-order the FTC procedure for ∫ₐᵇ f(x) dx.',
          shuffledSteps: [
            'Subtract: F(b) − F(a)',
            'Find an antiderivative F such that F\'(x) = f(x)',
            'Evaluate F at b',
            'Evaluate F at a',
          ],
          correctOrder: [1, 2, 3, 0],
        ),
        McqScreen(
          itemId: 'ftc-mcq',
          prompt: 'In ∫ₐᵇ f(x) dx = F(b) − F(a), what is F?',
          options: [
            McqOption(label: 'Any antiderivative of f'),
            McqOption(
              label: 'The derivative of f',
              misconceptionNote: 'Derivative goes the other way!',
            ),
            McqOption(
              label: 'f itself',
              misconceptionNote: 'F is f\'s antiderivative, not f.',
            ),
            McqOption(
              label: 'The area function only',
              misconceptionNote: 'Any antiderivative works — the +C cancels in subtraction.',
            ),
          ],
          correctIndex: 0,
          solutionHint:
              'F is any function whose derivative is f. The FTC turns area-finding into reverse-differentiation.',
        ),
        SummaryScreen(
          itemId: 'ftc-summary',
          title: 'Fundamental Theorem unlocked',
          takeaway:
              'To find ∫ₐᵇ f(x) dx, find F with F\' = f, then compute F(b) − F(a).',
          formula: '∫ₐᵇ f(x) dx = F(b) − F(a),  where F\' = f',
        ),
      ],
    ),
  ],
);
