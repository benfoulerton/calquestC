import 'package:flutter/material.dart';

import '../models/user_progress.dart';
import '../theme/app_theme.dart';

/// A toast that slides in from the top when a new achievement unlocks.
class AchievementToast extends StatefulWidget {
  final Achievement? achievement;
  final VoidCallback onDone;

  const AchievementToast({
    super.key,
    required this.achievement,
    required this.onDone,
  });

  @override
  State<AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<AchievementToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  Achievement? _shown;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _ac.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        widget.onDone();
        if (mounted) setState(() => _shown = null);
      }
    });
    _maybeStart();
  }

  @override
  void didUpdateWidget(covariant AchievementToast old) {
    super.didUpdateWidget(old);
    _maybeStart();
  }

  void _maybeStart() {
    if (widget.achievement != null && widget.achievement?.id != _shown?.id) {
      _shown = widget.achievement;
      _ac
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = _shown;
    if (a == null) return const SizedBox.shrink();
    return Positioned(
      top: 0,
      left: 12,
      right: 12,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _ac,
          builder: (_, __) {
            final t = _ac.value;
            final fade = t < 0.15
                ? t / 0.15
                : t > 0.85
                    ? 1 - ((t - 0.85) / 0.15)
                    : 1.0;
            final dy = (1 - fade) * -40;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Opacity(
                opacity: fade.clamp(0, 1).toDouble(),
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(a.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Achievement unlocked',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              a.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
