// lib/screens/lesson_result_screen.dart
//
// Shown after a lesson. Stars, XP gained, accuracy %, streak update, and
// an optional surprise chest every Nth lesson.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/curriculum.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LessonResultScreen extends StatefulWidget {
  const LessonResultScreen({
    super.key,
    required this.lessonId,
    required this.correct,
    required this.total,
    required this.showChest,
  });

  final String lessonId;
  final int correct;
  final int total;
  final bool showChest;

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen> {
  bool _chestOpened = false;
  String? _chestReward;

  static const _possibleRewards = [
    '+10 bonus XP',
    'Theme unlock: Sunset',
    'Theme unlock: Coral',
    'Streak freeze',
    'Double XP next lesson',
  ];

  void _openChest() {
    final r = _possibleRewards[Random().nextInt(_possibleRewards.length)];
    setState(() {
      _chestOpened = true;
      _chestReward = r;
    });
    final app = context.read<AppState>();
    if (r.contains('Sunset')) app.unlockTheme('sunset');
    if (r.contains('Coral')) app.unlockTheme('coral');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppPalette.fromScheme(scheme);
    final app = context.watch<AppState>();
    final lesson = Curriculum.findById(widget.lessonId);
    final stars = (app.progress.lessonStars[widget.lessonId] ?? 0);
    final accuracy =
        widget.total == 0 ? 100.0 : (widget.correct / widget.total) * 100;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                stars == 3
                    ? 'Perfect!'
                    : stars == 2
                        ? 'Great work!'
                        : stars == 1
                            ? 'Done.'
                            : 'Keep going!',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  duration: 400.ms),
              const SizedBox(height: 8),
              if (lesson != null)
                Text(lesson.title,
                    style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              // Stars row.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 56,
                      color: i < stars ? palette.streak : scheme.outlineVariant,
                    )
                        .animate(delay: (200 + i * 150).ms)
                        .scale(
                            begin: const Offset(0.3, 0.3),
                            end: const Offset(1, 1),
                            curve: Curves.easeOutBack,
                            duration: 350.ms),
                    if (i < 2) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Accuracy',
                      value: '${accuracy.round()}%',
                      icon: Icons.track_changes_rounded,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'XP',
                      value: '+${app.xpJustGained.value ?? 0}',
                      icon: Icons.bolt_rounded,
                      color: palette.streak,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Streak',
                      value: '${app.progress.currentStreak}🔥',
                      icon: Icons.local_fire_department_rounded,
                      color: palette.streak,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (widget.showChest) _buildChest(scheme, palette),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    app.clearXpToast();
                    context.go('/');
                  },
                  child: const Text('Back to home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChest(ColorScheme scheme, AppPalette palette) {
    if (!_chestOpened) {
      return Center(
        child: GestureDetector(
          onTap: _openChest,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radLarge),
              border: Border.all(color: scheme.tertiary, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.card_giftcard_rounded,
                    size: 44, color: scheme.onTertiaryContainer),
                const SizedBox(height: 8),
                Text('Surprise!',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('Tap to open',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        )
            .animate()
            .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 800.ms,
                curve: Curves.elasticOut)
            .shimmer(duration: 1200.ms, color: scheme.tertiary),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radLarge),
      ),
      child: Column(
        children: [
          Icon(Icons.celebration_rounded,
              size: 36, color: scheme.onTertiaryContainer),
          const SizedBox(height: 8),
          Text('You got:',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(_chestReward ?? '',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: scheme.onTertiaryContainer)),
        ],
      ).animate().fadeIn().scale(
          begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radLarge),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
