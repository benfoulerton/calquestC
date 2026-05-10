// lib/widgets/questions/passive_screens.dart
//
// Non-question screens: hook (auto-animation), explore (slider), worked
// example (tap-to-reveal), summary (recap). They all expose an
// "onContinue" callback the runner uses for advancement.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/micro_screen.dart';
import '../../theme/app_theme.dart';
import '../diagrams/diagram_dispatcher.dart';

/// HOOK — pure animation, "Got it" button below.
class HookScreenView extends StatelessWidget {
  const HookScreenView({
    super.key,
    required this.screen,
    required this.onContinue,
  });

  final HookScreen screen;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(screen.title, style: Theme.of(context).textTheme.headlineMedium)
            .animate()
            .fadeIn(duration: 300.ms)
            .moveY(begin: 8, end: 0),
        const SizedBox(height: 8),
        Text(
          screen.subtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate(delay: 120.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radLarge),
            ),
            padding: const EdgeInsets.all(12),
            child: DiagramView(kind: screen.diagram, autoAnimate: true),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onContinue,
            child: const Text('Got it'),
          ),
        ),
      ],
    );
  }
}

/// EXPLORE — interactive slider on the diagram.
class ExploreScreenView extends StatefulWidget {
  const ExploreScreenView({
    super.key,
    required this.screen,
    required this.onContinue,
  });

  final ExploreScreen screen;
  final VoidCallback onContinue;

  @override
  State<ExploreScreenView> createState() => _ExploreScreenViewState();
}

class _ExploreScreenViewState extends State<ExploreScreenView> {
  late double _v;

  @override
  void initState() {
    super.initState();
    _v = widget.screen.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.screen.title,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(widget.screen.prompt,
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radLarge),
            ),
            padding: const EdgeInsets.all(12),
            child: DiagramView(kind: widget.screen.diagram, controlValue: _v),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTheme.radMedium),
          ),
          child: Row(
            children: [
              Text(widget.screen.sliderLabel,
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _v,
                  min: widget.screen.minValue,
                  max: widget.screen.maxValue,
                  onChanged: (v) => setState(() => _v = v),
                ),
              ),
              Text(_v.toStringAsFixed(2),
                  style: mathStyle(context, size: 14, weight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.onContinue,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

/// WORKED EXAMPLE — tap "Next" to reveal each step in turn.
class WorkedExampleView extends StatefulWidget {
  const WorkedExampleView({
    super.key,
    required this.screen,
    required this.onContinue,
  });

  final WorkedExampleScreen screen;
  final VoidCallback onContinue;

  @override
  State<WorkedExampleView> createState() => _WorkedExampleViewState();
}

class _WorkedExampleViewState extends State<WorkedExampleView> {
  int _revealed = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allRevealed = _revealed >= widget.screen.steps.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.screen.title,
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppTheme.radLarge),
          ),
          child: Row(
            children: [
              Icon(Icons.help_outline_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.screen.problem,
                  style: mathStyle(context, size: 16, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _revealed; i++) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppTheme.radMedium),
                      border: Border.all(
                          color: scheme.outlineVariant, width: 1.2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: scheme.primaryContainer,
                          child: Text('${i + 1}',
                              style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.screen.steps[i].text,
                            style: mathStyle(context, size: 15),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 220.ms).moveY(begin: 8, end: 0),
                  const SizedBox(height: 8),
                ],
                if (allRevealed) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radLarge),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.screen.result,
                            style: mathStyle(context,
                                    size: 16, weight: FontWeight.w800)
                                .copyWith(color: scheme.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 280.ms).scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1, 1)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              if (allRevealed) {
                widget.onContinue();
              } else {
                setState(() => _revealed++);
              }
            },
            child: Text(allRevealed ? 'Continue' : 'Next step'),
          ),
        ),
      ],
    );
  }
}

/// SUMMARY — brief recap card before reward screen.
class SummaryScreenView extends StatelessWidget {
  const SummaryScreenView({
    super.key,
    required this.screen,
    required this.onContinue,
  });

  final SummaryScreen screen;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded,
              size: 56, color: scheme.onPrimaryContainer),
        )
            .animate()
            .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.easeOutBack)
            .fadeIn(),
        const SizedBox(height: 24),
        Text(
          screen.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall,
        ).animate(delay: 120.ms).fadeIn(),
        const SizedBox(height: 12),
        Text(
          screen.takeaway,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate(delay: 200.ms).fadeIn(),
        if (screen.formula != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radLarge),
            ),
            child: Center(
              child: Text(
                screen.formula!,
                textAlign: TextAlign.center,
                style: mathStyle(context, size: 18, weight: FontWeight.w800),
              ),
            ),
          ).animate(delay: 280.ms).fadeIn(),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}
