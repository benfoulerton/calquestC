import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small chip showing the user's current daily streak with a flame icon.
class StreakBadge extends StatelessWidget {
  final int streak;
  final bool large;
  const StreakBadge({super.key, required this.streak, this.large = false});

  @override
  Widget build(BuildContext context) {
    final scale = large ? 1.25 : 1.0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.warning,
            size: 18 * scale,
          ),
          SizedBox(width: 4 * scale),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w800,
                  fontSize: 14 * scale,
                ),
          ),
        ],
      ),
    );
  }
}
