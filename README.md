# Calculus Quest v2

A Duolingo-style, ADHD-friendly calculus learning app for Android, built in
Flutter with **Material 3 Expressive** theming and an **FSRS-lite** spaced-
repetition system.

## What's new in v2

This is a complete pedagogical rebuild. v1 used a textbook-style "read four
paragraphs, then quiz" structure. v2 uses **micro-screen lesson sequences**:
3–5 minute lessons of 10–15 single-screen interactions, each one of:

- **Visual hook** — animated diagram, no input
- **Explore slider** — drag a slider, watch the diagram react
- **Worked example** — tap-through stepped reveal
- **Tap-to-match** — pair items left ↔ right
- **Fill-in-the-blank** — pick a token to complete an equation
- **Tap-the-graph** — choose the right shape from 3-4 options
- **Estimate** — drag a slider to estimate slope/area, tolerance scoring
- **Build expression** — tap pieces to assemble an answer
- **Reorder steps** — drag derivation steps into the right order
- **Multiple choice** — distractors target known misconceptions
- **Summary** — recap with formula

Every diagram is a custom `CustomPainter` driven by an `AnimationController`
or external slider — drag a tangent line along `y = x²`, slide `n` higher
to see Riemann rectangles converge, watch a secant rotate into a tangent
as `h → 0`.

## Material 3 Expressive

- Full M3 colour scheme generated via `ColorScheme.fromSeed`
- 9 named theme presets: Ocean, Forest, Sunset, Synthwave, Mono, Coral,
  Mint, Indigo, Amber
- Optional Android 12+ wallpaper-derived dynamic colour via
  `dynamic_color`
- Light + dark mode
- Reduce-motion / sound / haptics toggles
- Big radii (24/12), pill chips, tone-based surfaces

## FSRS-lite review

Every question has an `itemId`. On a wrong answer:

- The item gets requeued once for end-of-lesson retry
- The item's review-stability shrinks; it'll be due sooner
- The item appears on the **Review** tab when due
- Tapping "Start review" runs a synthetic lesson made of just those items

Stability roughly doubles per success (cap 365 days), shrinks to 40% per
failure. Simpler than full FSRS but captures the spaced-repetition shape
the brief calls for.

## Engagement loop

- XP per correct question + per lesson + perfect / streak bonuses
- Streak counter with 2 free freezes per week
- Surprise chest every 5th lesson — 1 of 5 random rewards (theme unlocks,
  bonus XP, etc.)
- Daily quests
- Achievements (First Steps, Five Down, Week Warrior, …)

## Build

```sh
flutter pub get
flutter run            # debug
flutter build apk      # release APK
```

Compatible with Codemagic build pipeline. AGP 8.6.0, Kotlin 2.1.0,
compileSdk 36.

## Project structure

```
lib/
├── main.dart                            entry, MaterialApp.router
├── data/
│   ├── curriculum.dart                  aggregator
│   ├── unit_functions.dart              functions & limits
│   ├── unit_derivatives.dart            derivatives + power rule + special
│   └── unit_integrals.dart              Riemann, notation, FTC
├── models/
│   ├── micro_screen.dart                sealed class for all screen types
│   ├── lesson.dart                      Lesson + Unit
│   └── user_progress.dart               XP, streak, FSRS-lite ReviewItem
├── providers/
│   └── app_state.dart                   ChangeNotifier — single source of truth
├── services/
│   └── storage_service.dart             SharedPreferences wrapper
├── theme/
│   └── app_theme.dart                   M3 Expressive ThemeData + presets
├── screens/
│   ├── main_shell.dart                  bottom nav + global toasts
│   ├── home_screen.dart                 dashboard + Continue button
│   ├── path_screen.dart                 zigzag lesson path
│   ├── review_screen.dart               FSRS-lite due queue
│   ├── stats_screen.dart                XP / accuracy / per-unit progress
│   ├── settings_screen.dart             theme picker, comfort toggles
│   ├── lesson_runner_screen.dart        the orchestrator
│   └── lesson_result_screen.dart        celebration / chest
├── utils/
│   └── app_router.dart                  go_router config
└── widgets/
    ├── diagrams/                        7 animated CustomPainter diagrams
    ├── questions/                       7 interactive question widgets
    └── common/                          (reserved)
```

Pedagogy follows the brief in `Rebuilding a Calculus App as Duolingo for ADHD`.
