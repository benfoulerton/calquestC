import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/achievements.dart';
import '../models/user_progress.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';

/// Displays all achievements as a grid: earned ones in colour, locked ones
/// dimmed to silhouettes. Tapping a badge shows its description.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>().progress;
    final earnedCount = Achievements.all
        .where((a) => progress.earnedAchievementIds.contains(a.id))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$earnedCount of ${Achievements.all.length}',
                            style:
                                Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 2),
                          Text('Badges earned',
                              style:
                                  Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: Achievements.all.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (_, i) {
                final a = Achievements.all[i];
                final earned = progress.earnedAchievementIds.contains(a.id);
                return _BadgeTile(
                  achievement: a,
                  earned: earned,
                  onTap: () => _showDetail(context, a, earned),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(
      BuildContext context, Achievement a, bool earned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: earned
                    ? AppColors.primary.withOpacity(0.12)
                    : Theme.of(context).dividerColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                a.emoji,
                style: TextStyle(
                  fontSize: 36,
                  color: earned ? null : AppColors.textFaint,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(a.title,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(a.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: earned
                    ? AppColors.success.withOpacity(0.12)
                    : Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                earned ? 'Earned' : 'Locked',
                style: TextStyle(
                  color:
                      earned ? AppColors.success : AppColors.textFaint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Achievement achievement;
  final bool earned;
  final VoidCallback onTap;
  const _BadgeTile({
    required this.achievement,
    required this.earned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned
                ? AppColors.primary.withOpacity(0.4)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: earned
                    ? AppColors.primary.withOpacity(0.12)
                    : Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 24,
                  color: earned ? null : AppColors.textFaint,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  achievement.title,
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: earned
                                ? null
                                : AppColors.textFaint,
                            fontSize: 14,
                          ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: AppColors.textFaint,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
