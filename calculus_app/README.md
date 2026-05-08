# Calculus Quest

A Duolingo-style calculus learning app for Android, built in Flutter and powered
by a complete Stewart Calculus 9e course (116 lessons across 16 chapters, 580
practice questions, ~1,800 XP). Designed to feel clean, modern, academic, and
motivating — never childish.

The app dynamically loads its content from a single bundled JSON file, so the
curriculum, formulas, examples, common mistakes, and questions are all data,
not hardcoded UI.

---

## Getting started

You need:

- Flutter (stable channel, 3.10 or later)
- An Android device or emulator
- Java 17 + Android SDK 34 if you plan to build a release APK

```bash
cd calculus_app
flutter pub get
flutter run                   # runs on a connected device or emulator
flutter build apk --release   # produces build/app/outputs/flutter-apk/app-release.apk
```

If `flutter pub get` complains about missing Android tooling, run:

```bash
flutter doctor
```

…and follow the suggestions. The app targets Android only — iOS, web, and
desktop scaffolding has been omitted to keep the project tight.

> **Note on signing:** the bundled `android/app/build.gradle` reuses the debug
> signing config for `release` builds, which is fine for sideloading and
> testing. To publish to the Play Store, generate a real keystore and replace
> the `signingConfig` block.

---

## Project structure

```
calculus_app/
├── android/                              # standard Flutter Android project
├── assets/
│   └── data/
│       └── stewart_calculus_course.json  # the entire course (loaded at runtime)
├── lib/
│   ├── main.dart                         # app entry point + MultiProvider
│   ├── data/
│   │   └── daily_quotes.dart             # 30-quote rotating bank
│   ├── models/
│   │   ├── achievements.dart             # static badge catalogue
│   │   ├── course.dart                   # Course / Unit / Topic / Lesson / Question
│   │   └── user_progress.dart            # XP, streak, completion, etc.
│   ├── providers/
│   │   ├── course_provider.dart
│   │   ├── progress_provider.dart        # XP, streak, achievement orchestration
│   │   └── settings_provider.dart        # dark mode, sound
│   ├── screens/
│   │   ├── achievements_screen.dart
│   │   ├── home_screen.dart
│   │   ├── lesson_screen.dart
│   │   ├── loading_screen.dart
│   │   ├── main_shell.dart               # bottom nav scaffold + global toasts
│   │   ├── path_screen.dart              # Duolingo-style course map
│   │   ├── quiz_result_screen.dart
│   │   ├── quiz_screen.dart              # MCQ + numerical input
│   │   ├── review_screen.dart            # weakest lessons surface
│   │   ├── search_screen.dart
│   │   ├── settings_screen.dart
│   │   └── stats_screen.dart             # custom-painted accuracy chart
│   ├── services/
│   │   ├── course_service.dart           # rootBundle JSON loader (cached)
│   │   └── storage_service.dart          # shared_preferences wrapper
│   ├── theme/
│   │   └── app_theme.dart                # Material 3 light + dark
│   ├── utils/
│   │   ├── answer_checker.dart           # input answer comparison
│   │   └── app_router.dart               # go_router setup
│   └── widgets/
│       ├── achievement_toast.dart
│       ├── content_cards.dart            # FormulaCard / MistakesCard / ExampleCard
│       ├── math_text.dart                # Unicode + LaTeX renderer
│       ├── primary_button.dart
│       ├── streak_badge.dart
│       ├── xp_gain_overlay.dart
│       └── xp_progress_bar.dart
├── pubspec.yaml
└── README.md
```

---

## How it works

### Data layer

`assets/data/stewart_calculus_course.json` is the single source of truth. On
startup, `CourseProvider.load()` calls `CourseService.instance.loadCourse()`
which reads the asset via `rootBundle`, parses it once, and caches it. All
screens read from the same parsed `Course` object.

The JSON shape:

```json
{
  "course": "Stewart Calculus: Early Transcendentals 9e",
  "total_lessons": 116,
  "total_questions": 580,
  "units": [
    {
      "unit_number": 1,
      "title": "Functions and Models",
      "topics": [
        {
          "title": "...",
          "lessons": [
            {
              "title": "1.1 Four Ways to Represent a Function",
              "explanation": "...",
              "formulas": ["..."],
              "examples": [{ "setup": "...", "steps": ["..."], "result": "..." }],
              "common_mistakes": ["..."],
              "questions": [{ "type": "mcq", "prompt": "...", "options": ["..."], "correct_index": 0, "solution": "..." }],
              "answers": ["..."],
              "xp": 14,
              "difficulty": 2
            }
          ]
        }
      ]
    }
  ]
}
```

### Progress

Every XP change, streak update, lesson completion, and achievement unlock goes
through `ProgressProvider`. State is serialised to JSON and saved in
`shared_preferences` under the key `progress.v1`. Two `ValueNotifier`s expose
fresh-event signals (`xpJustGained`, `newlyEarned`) so the global overlays in
`MainShell` can pop animated toasts above any screen.

### Lesson chain

Lessons are unlocked in course order. The first lesson is always available;
each subsequent lesson unlocks when its predecessor is completed. This mirrors
Duolingo's path-style progression and is implemented in
`ProgressProvider.isUnlocked`.

### Answer checking

`AnswerChecker.isCorrect(user, expected)` normalises Unicode (∫, ², minus
signs, etc.), strips whitespace, and falls back to numerical equivalence
within a 2% tolerance — including simple `a/b` fractions. This keeps numerical
input forgiving without the complexity of a full expression parser.

### Math rendering

`MathText` renders Unicode math in Roboto Mono (which handles ∫, ∂, π, ², etc.
gracefully). When content looks like real LaTeX (backslashes or `^{...}`), it
attempts `flutter_math_fork` and silently falls back to text on failure.

---

## Customising

- **Add or edit lessons:** edit `assets/data/stewart_calculus_course.json` and
  hot-restart. The models accept additional fields without breaking.
- **Theme:** change `AppColors` or `AppTheme.light/dark` in
  `lib/theme/app_theme.dart`. The whole app re-themes automatically.
- **Achievements:** add an entry to `Achievements.all` in
  `lib/models/achievements.dart` with a predicate. New achievements
  automatically unlock retroactively when their predicate matches.

---

## What's covered (versus the brief)

- ✅ Course map with Duolingo-style zig-zag and unlocked / locked nodes
- ✅ Lesson system with explanation, formulas, examples, common mistakes
- ✅ Quiz system with MCQ + numerical input + instant feedback
- ✅ XP, levels (every 100 XP), daily streak with bonus, accuracy tracking
- ✅ Home screen with greeting, streak, XP bar, daily quote, recent lessons
- ✅ Stats screen with mini-grid + per-chapter accuracy bar chart
- ✅ Settings: dark mode, sound, reset, clipboard export, JSON import
- ✅ Achievements grid with earned/locked states and detail sheet
- ✅ Search across titles + explanations with snippet previews
- ✅ Smart review of lessons under 80% accuracy
- ✅ Animated +XP popup and slide-in achievement toast
- ✅ Beautiful animated loading screen
- ✅ Proper dark mode throughout
- ✅ Complete offline operation — no network calls anywhere
