import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

/// User statistics: XP, lessons completed, time studied, plus a simple
/// per-chapter accuracy bar graph rendered with CustomPaint.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    final progressProv = context.watch<ProgressProvider>();

    if (courseProv.isLoading || courseProv.course == null) {
      return const LoadingScreen();
    }
    final course = courseProv.course!;
    final p = progressProv.progress;

    final accuracyByChapter = <int, int>{};
    final completedByChapter = <int, int>{};
    for (final unit in course.units) {
      var sum = 0;
      var n = 0;
      var done = 0;
      for (final l in unit.lessons) {
        if (p.completedLessonIds.contains(l.id)) {
          done++;
          sum += p.lessonAccuracy[l.id] ?? 0;
          n++;
        }
      }
      accuracyByChapter[unit.unitNumber] = n == 0 ? 0 : (sum / n).round();
      completedByChapter[unit.unitNumber] = done;
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Statistics',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _BigStatCard(
                icon: Icons.bolt_rounded,
                color: AppColors.warning,
                label: 'Total XP',
                value: '${p.xp}',
              ),
              _BigStatCard(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                label: 'Lessons done',
                value: '${p.completedLessonIds.length}/${course.totalLessons}',
              ),
              _BigStatCard(
                icon: Icons.percent_rounded,
                color: AppColors.primary,
                label: 'Accuracy',
                value: '${p.lifetimeAccuracy.toStringAsFixed(0)}%',
              ),
              _BigStatCard(
                icon: Icons.schedule_rounded,
                color: AppColors.accent,
                label: 'Time studied',
                value: _formatDuration(p.totalSecondsStudied),
              ),
              _BigStatCard(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
                label: 'Current streak',
                value: '${p.currentStreak}d',
              ),
              _BigStatCard(
                icon: Icons.emoji_events_rounded,
                color: AppColors.primary,
                label: 'Best streak',
                value: '${p.longestStreak}d',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bar_chart_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Accuracy by chapter',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: _AccuracyBarPainter(
                        accuracyByChapter: accuracyByChapter,
                        units: course.units,
                        baseColor: Theme.of(context).dividerColor,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bars represent average accuracy across completed lessons in each chapter.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppColors.textFaint,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Chapter progress',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final unit in course.units) ...[
                    _ChapterProgressRow(
                      unit: unit,
                      completed: completedByChapter[unit.unitNumber] ?? 0,
                    ),
                    if (unit.unitNumber != course.units.length)
                      const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final m = totalSeconds ~/ 60;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final mm = m % 60;
    return '${h}h ${mm}m';
  }
}

class _BigStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _BigStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 2),
              Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppColors.textFaint,
                      )),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChapterProgressRow extends StatelessWidget {
  final Unit unit;
  final int completed;
  const _ChapterProgressRow({required this.unit, required this.completed});

  @override
  Widget build(BuildContext context) {
    final total = unit.lessons.length;
    final pct = total == 0 ? 0.0 : completed / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ch ${unit.unitNumber}: ${unit.title}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('$completed/$total',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textFaint,
                    )),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            color: AppColors.primary,
            backgroundColor: Theme.of(context).dividerColor,
          ),
        ),
      ],
    );
  }
}

/// Custom painter rendering a simple accuracy bar chart for chapters 1..16.
class _AccuracyBarPainter extends CustomPainter {
  final Map<int, int> accuracyByChapter;
  final List<Unit> units;
  final Color baseColor;

  _AccuracyBarPainter({
    required this.accuracyByChapter,
    required this.units,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = units.length;
    if (n == 0) return;
    const labelArea = 28.0;
    final chartHeight = size.height - labelArea;
    final barAreaWidth = size.width / n;
    final barWidth = barAreaWidth * 0.55;
    final paintBg = Paint()..color = baseColor;
    final paintBar = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.accent],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, chartHeight));

    final textStyle = TextStyle(
      color: baseColor.computeLuminance() > 0.6
          ? const Color(0xFF94A3B8)
          : const Color(0xFF64748B),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    for (var i = 0; i < n; i++) {
      final acc = (accuracyByChapter[units[i].unitNumber] ?? 0).clamp(0, 100);
      final cx = i * barAreaWidth + barAreaWidth / 2;
      final left = cx - barWidth / 2;
      final h = (acc / 100) * (chartHeight - 8);
      // Background bar.
      final rectBg = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, barWidth, chartHeight),
        const Radius.circular(6),
      );
      canvas.drawRRect(rectBg, paintBg);
      // Foreground.
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, chartHeight - h, barWidth, h),
        const Radius.circular(6),
      );
      canvas.drawRRect(rect, paintBar);
      // Chapter label.
      final tp = TextPainter(
        text: TextSpan(text: '${units[i].unitNumber}', style: textStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas,
          Offset(cx - tp.width / 2, chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _AccuracyBarPainter old) {
    return old.accuracyByChapter != accuracyByChapter;
  }
}
