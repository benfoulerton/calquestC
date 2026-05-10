// lib/data/unit_functions.dart
//
// Unit 1: Functions, Limits & the Derivative Idea.
//
// Each lesson follows the research-brief template:
//   1. Hook (visual, no input)
//   2. Explore (slider, no wrong answer)
//   3. Worked example (tap-through)
//   4. Recognition (match)
//   5. Completion (fill-blank)
//   6. Concept-image (tap-graph)
//   7. Slider intuition (estimate)
//   8. Build expression
//   9. MCQ (with misconception distractors)
//   10. Summary
//
// We don't replicate every lesson with all 10 — we mix types per topic.

import '../models/lesson.dart';
import '../models/micro_screen.dart';

final unitFunctions = Unit(
  id: 'u-functions',
  title: 'Functions & Limits',
  tagline: 'The starting line.',
  icon: '∿',
  lessons: [
    // ── L1: What is a function? ────────────────────────────────────────
    Lesson(
      id: 'l-function-intro',
      title: 'What is a function?',
      subtitle: 'A machine that takes an input and produces an output.',
      icon: '⚙',
      xpReward: 10,
      screens: [
        HookScreen(
          itemId: 'function-machine',
          title: 'Watch the machine',
          subtitle: 'A function takes inputs and gives outputs.',
          diagram: DiagramKind.functionMachine,
          durationMs: 5000,
        ),
        TapMatchScreen(
          itemId: 'function-machine',
          prompt: 'Match each input to its output for f(x) = x + 2.',
          pairs: [
            MatchPair(left: 'x = 0', right: '2'),
            MatchPair(left: 'x = 3', right: '5'),
            MatchPair(left: 'x = -1', right: '1'),
            MatchPair(left: 'x = 10', right: '12'),
          ],
        ),
        FillBlankScreen(
          itemId: 'function-eval',
          prompt: 'If f(x) = 3x, what is f(4)?',
          beforeBlank: 'f(4) = ',
          afterBlank: '',
          options: ['7', '12', '4', '1'],
          correctIndex: 1,
          solutionHint: 'Substitute x = 4 into 3x.',
        ),
        McqScreen(
          itemId: 'function-vlt',
          prompt: 'Which of these is NOT a function?',
          options: [
            McqOption(label: 'y = x²'),
            McqOption(
              label: 'x = y² (sideways parabola)',
              misconceptionNote:
                  'A vertical line at x = 1 hits this curve at both y = 1 and y = -1.',
            ),
            McqOption(label: 'y = 2x + 1'),
            McqOption(label: 'y = sin x'),
          ],
          correctIndex: 1,
          solutionHint:
              'The vertical-line test: each x must give exactly one y.',
        ),
        SummaryScreen(
          itemId: 'function-intro-summary',
          title: 'Nice. You\'ve got it.',
          takeaway:
              'A function takes one input, gives one output. No surprises.',
          formula: 'f: input ⟶ output',
        ),
      ],
    ),

    // ── L2: Reading graphs ──────────────────────────────────────────────
    Lesson(
      id: 'l-graphs',
      title: 'Reading graphs',
      subtitle: 'Pictures of functions.',
      icon: '📈',
      xpReward: 12,
      screens: [
        HookScreen(
          itemId: 'graph-reading',
          title: 'Graphs are stories',
          subtitle:
              'A graph shows what a function does for every input at once.',
          diagram: DiagramKind.functionMachine,
          durationMs: 4500,
        ),
        TapGraphScreen(
          itemId: 'graph-recognise-line',
          prompt: 'Tap the graph of y = x.',
          options: [
            GraphFunc.linearPos,
            GraphFunc.parabolaUp,
            GraphFunc.sine,
            GraphFunc.constant,
          ],
          correctIndex: 0,
          solutionHint: 'A straight line through the origin with slope 1.',
        ),
        TapGraphScreen(
          itemId: 'graph-recognise-parabola',
          prompt: 'Tap the graph of y = x².',
          options: [
            GraphFunc.linearPos,
            GraphFunc.absolute,
            GraphFunc.parabolaUp,
            GraphFunc.cubic,
          ],
          correctIndex: 2,
          solutionHint: 'A symmetric U-shape opening upward.',
        ),
        TapGraphScreen(
          itemId: 'graph-recognise-sin',
          prompt: 'Tap the graph of y = sin x.',
          options: [
            GraphFunc.cosine,
            GraphFunc.sine,
            GraphFunc.cubic,
            GraphFunc.exp,
          ],
          correctIndex: 1,
          solutionHint: 'sin starts at 0; cos starts at 1.',
        ),
        TapMatchScreen(
          itemId: 'graph-match',
          prompt: 'Match each function to its shape.',
          pairs: [
            MatchPair(left: 'y = x²', right: 'U-shape'),
            MatchPair(left: 'y = x³', right: 'S-curve'),
            MatchPair(left: 'y = |x|', right: 'V-shape'),
            MatchPair(left: 'y = √x', right: 'Half-curve'),
          ],
        ),
        SummaryScreen(
          itemId: 'graphs-summary',
          title: 'Graph fluency unlocked',
          takeaway:
              'Each shape tells you something. Lines stay straight, parabolas bend once, cubics bend twice.',
        ),
      ],
    ),

    // ── L3: The idea of a limit ─────────────────────────────────────────
    Lesson(
      id: 'l-limits-intro',
      title: 'The limit idea',
      subtitle: 'Where is the function heading?',
      icon: '→',
      xpReward: 14,
      screens: [
        HookScreen(
          itemId: 'limit-shrink',
          title: 'Get closer and closer',
          subtitle:
              'A limit asks: as x approaches a number, where does y go?',
          diagram: DiagramKind.limitShrink,
          durationMs: 6000,
        ),
        ExploreScreen(
          itemId: 'limit-explore',
          title: 'Pull x toward 2',
          prompt:
              'Drag the slider. As x gets close to 2, watch where f(x) = x + 1 lands.',
          diagram: DiagramKind.limitShrink,
          sliderLabel: 'x',
          minValue: 1.0,
          maxValue: 3.0,
          initialValue: 1.0,
        ),
        WorkedExampleScreen(
          itemId: 'limit-worked',
          title: 'A worked example',
          problem: 'Find lim_{x→3} (x + 1).',
          steps: [
            ExampleStep(text: 'Substitute x = 3 directly: 3 + 1.'),
            ExampleStep(text: 'Result: 4.'),
            ExampleStep(
                text: 'For continuous functions, plug in works. Done.'),
          ],
          result: 'lim_{x→3} (x + 1) = 4',
        ),
        FillBlankScreen(
          itemId: 'limit-eval',
          prompt: 'Find lim_{x→2} (x² − 1).',
          beforeBlank: 'lim_{x→2} (x² − 1) = ',
          afterBlank: '',
          options: ['3', '4', '−3', '1'],
          correctIndex: 0,
          solutionHint: 'Substitute: 2² − 1 = 4 − 1 = 3.',
        ),
        McqScreen(
          itemId: 'limit-zero-zero',
          prompt: 'What does lim_{x→0} (sin x / x) equal?',
          options: [
            McqOption(label: '0', misconceptionNote: 'Top is 0 but bottom is also 0 — not a clean substitution.'),
            McqOption(label: '1'),
            McqOption(label: '∞', misconceptionNote: 'Both numerator and denominator vanish; not infinity.'),
            McqOption(label: 'undefined', misconceptionNote: 'It LOOKS undefined at x=0, but the limit exists.'),
          ],
          correctIndex: 1,
          solutionHint:
              'Famous limit. The graph squeezes toward 1 from both sides as x → 0.',
        ),
        SummaryScreen(
          itemId: 'limit-summary',
          title: 'Limits = where you\'re heading',
          takeaway:
              'A limit asks: as x approaches some value, where does the function go? Often you can just substitute.',
          formula: 'lim_{x→a} f(x) = the value f is heading toward',
        ),
      ],
    ),
  ],
);
