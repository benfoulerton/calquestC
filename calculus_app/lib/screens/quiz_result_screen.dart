import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// Post-quiz celebration screen. Shows accuracy, XP, and offers to continue.
class QuizResultScreen extends StatelessWidget {
  final String lessonId;
  final int correct;
  final int total;
  final int xpEarned;

  const QuizResultScreen({
    super.key,
    required this.lessonId,
    required this.correct,
    required this.total,
    required this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    final acc = total == 0 ? 0 : (correct / total * 100).round();
    final passed = acc >= 60;
    final tone = passed ? AppColors.success : AppColors.warning;

    final course = context.read<CourseProvider>().course;
    final progress = context.read<ProgressProvider>();
    final next = course == null ? null : progress.nextLesson(course);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (_, v, __) => Transform.scale(
                  scale: v,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: tone.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      passed
                          ? Icons.emoji_events_rounded
                          : Icons.replay_rounded,
                      color: tone,
                      size: 56,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Great work!' : 'Good effort!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                passed
                    ? 'Lesson complete. Keep it going.'
                    : 'You can review the lesson and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.percent_rounded,
                      label: 'Accuracy',
                      value: '$acc%',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.bolt_rounded,
                      label: 'XP earned',
                      value: '+$xpEarned',
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatCard(
                icon: Icons.check_circle_outline_rounded,
                label: 'Correct answers',
                value: '$correct of $total',
                color: AppColors.success,
                wide: true,
              ),
              const Spacer(),
              if (next != null)
                PrimaryButton(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Continue to next lesson',
                  onPressed: () => context
                      .go('/lesson/${Uri.encodeComponent(next.id)}'),
                ),
              if (next != null) const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => context.go('/path'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Back to path'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context
                    .go('/lesson/${Uri.encodeComponent(lessonId)}'),
                child: const Text('Review this lesson'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool wide;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppColors.textFaint,
                      )),
              const SizedBox(height: 2),
              Text(value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
            ],
          ),
        ],
      ),
    );
  }
}
