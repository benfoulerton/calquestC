import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import 'loading_screen.dart';

/// Search across lesson titles and explanations. Tapping a result opens
/// the lesson page. Locked lessons remain locked from here too.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    final progressProv = context.watch<ProgressProvider>();
    if (courseProv.isLoading || courseProv.course == null) {
      return const LoadingScreen();
    }
    final course = courseProv.course!;
    final results = _query.isEmpty
        ? <Lesson>[]
        : course.allLessons.where((l) {
            final q = _query.toLowerCase();
            return l.title.toLowerCase().contains(q) ||
                l.explanation.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search lessons'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. derivatives, integration by parts…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
            Expanded(
              child: _query.isEmpty
                  ? _SearchEmpty()
                  : results.isEmpty
                      ? _NoResults(query: _query)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _LessonResultCard(
                            lesson: results[i],
                            unlocked: progressProv.isUnlocked(
                                course, results[i]),
                            completed:
                                progressProv.isCompleted(results[i]),
                            query: _query,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Search the entire course',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Find a topic by title or by any term that appears in the explanation.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              color: AppColors.textFaint, size: 48),
          const SizedBox(height: 12),
          Text('No matches for "$query"',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Try a shorter or more general term.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _LessonResultCard extends StatelessWidget {
  final Lesson lesson;
  final bool unlocked;
  final bool completed;
  final String query;
  const _LessonResultCard({
    required this.lesson,
    required this.unlocked,
    required this.completed,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: !unlocked
            ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Complete the previous lesson to unlock this one.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                )
            : () =>
                context.push('/lesson/${Uri.encodeComponent(lesson.id)}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.success.withOpacity(0.12)
                      : unlocked
                          ? AppColors.primary.withOpacity(0.12)
                          : AppColors.lockedNode.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : !unlocked
                          ? Icons.lock_rounded
                          : Icons.menu_book_rounded,
                  color: completed
                      ? AppColors.success
                      : unlocked
                          ? AppColors.primary
                          : AppColors.textFaint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _snippet(lesson.explanation, query),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppColors.textFaint,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }

  /// Pulls a short window of text around the first match of [q] in [text]
  /// for a richer search-result preview.
  String _snippet(String text, String q) {
    if (q.isEmpty) return text;
    final lower = text.toLowerCase();
    final idx = lower.indexOf(q.toLowerCase());
    if (idx == -1) return text;
    final start = (idx - 30).clamp(0, text.length);
    final end = (idx + q.length + 80).clamp(0, text.length);
    final prefix = start > 0 ? '… ' : '';
    final suffix = end < text.length ? ' …' : '';
    return '$prefix${text.substring(start, end)}$suffix';
  }
}
