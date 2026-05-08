import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A slim XP progress bar that fills smoothly between the start of a level
/// (xpInLevel = 0) and the next level (xpInLevel = 100).
class XpProgressBar extends StatelessWidget {
  final int xpInLevel; // 0..100
  final int level;
  final double height;
  final bool showLabel;

  const XpProgressBar({
    super.key,
    required this.xpInLevel,
    required this.level,
    this.height = 12,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (xpInLevel.clamp(0, 100)) / 100;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = isDark
        ? AppColors.surfaceDarkElev
        : const Color(0xFFE6EAF2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $level',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$xpInLevel / 100 XP',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(color: track),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: v,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
