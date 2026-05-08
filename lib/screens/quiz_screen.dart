import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import '../utils/answer_checker.dart';
import '../widgets/math_text.dart';
import '../widgets/primary_button.dart';
import 'loading_screen.dart';

/// Sequentially presents the lesson's quiz questions. Per-question states:
///   answering -> feedback (correct / incorrect with solution) -> next.
class QuizScreen extends StatefulWidget {
  final String lessonId;
  const QuizScreen({super.key, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _correct = 0;
  bool _checked = false;
  bool _wasCorrect = false;
  int? _selectedOption;
  final TextEditingController _input = TextEditingController();
  late DateTime _start;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseProv = context.watch<CourseProvider>();
    if (courseProv.isLoading || courseProv.course == null) {
      return const LoadingScreen();
    }
    final course = courseProv.course!;
    final decoded = Uri.decodeComponent(widget.lessonId);
    final lesson = course.allLessons.firstWhere(
      (l) => l.id == decoded,
      orElse: () => course.allLessons.first,
    );
    final questions = lesson.questions;
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No questions in this lesson.')),
      );
    }

    final q = questions[_index];

    return WillPopScope(
      onWillPop: () async {
        return await _confirmExit() ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              if (await _confirmExit() == true) {
                if (context.mounted) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/path');
                  }
                }
              }
            },
          ),
          title: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (_index + (_checked ? 1 : 0)) / questions.length,
                    minHeight: 8,
                    color: AppColors.primary,
                    backgroundColor: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('${_index + 1}/${questions.length}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    Text(
                      'Question ${_index + 1}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textFaint,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: MathText(
                          q.prompt,
                          fontSize: 18,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (q.kind == QuestionKind.multipleChoice)
                      _McqOptions(
                        options: q.options,
                        selectedIndex: _selectedOption,
                        correctIndex: q.correctIndex,
                        showResult: _checked,
                        onTap: _checked
                            ? null
                            : (i) => setState(() => _selectedOption = i),
                      )
                    else
                      _InputBox(
                        controller: _input,
                        enabled: !_checked,
                      ),
                    if (_checked) ...[
                      const SizedBox(height: 20),
                      _FeedbackBox(
                        correct: _wasCorrect,
                        solution: q.solution,
                        expected: q.kind == QuestionKind.multipleChoice
                            ? (q.correctIndex >= 0 &&
                                    q.correctIndex < q.options.length
                                ? q.options[q.correctIndex]
                                : '')
                            : q.correctAnswer,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  label: _checked
                      ? (_index == questions.length - 1 ? 'Finish' : 'Next')
                      : 'Check',
                  icon: _checked
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded,
                  color: _checked
                      ? (_wasCorrect ? AppColors.success : AppColors.primary)
                      : AppColors.primary,
                  onPressed: _canAct(q) ? () => _onAction(lesson, q) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canAct(Question q) {
    if (_checked) return true;
    if (q.kind == QuestionKind.multipleChoice) {
      return _selectedOption != null;
    }
    return _input.text.trim().isNotEmpty;
  }

  void _onAction(Lesson lesson, Question q) async {
    if (!_checked) {
      // Check.
      bool correct = false;
      if (q.kind == QuestionKind.multipleChoice) {
        correct = _selectedOption == q.correctIndex;
      } else {
        correct = AnswerChecker.isCorrect(_input.text, q.correctAnswer);
      }
      setState(() {
        _checked = true;
        _wasCorrect = correct;
        if (correct) _correct++;
      });
    } else {
      // Advance or finish.
      final questions = lesson.questions;
      if (_index == questions.length - 1) {
        await _finish(lesson);
      } else {
        setState(() {
          _index++;
          _checked = false;
          _wasCorrect = false;
          _selectedOption = null;
          _input.clear();
        });
      }
    }
  }

  Future<void> _finish(Lesson lesson) async {
    final secondsSpent =
        DateTime.now().difference(_start).inSeconds.clamp(0, 1800);
    final progress = context.read<ProgressProvider>();
    final xpBefore = progress.progress.xp;
    await progress.recordLessonResult(
      lesson: lesson,
      correctCount: _correct,
      totalCount: lesson.questions.length,
      secondsSpent: secondsSpent,
    );
    final xpEarned = progress.progress.xp - xpBefore;
    if (!mounted) return;
    context.go('/result', extra: {
      'lessonId': lesson.id,
      'correct': _correct,
      'total': lesson.questions.length,
      'xpEarned': xpEarned,
    });
  }

  Future<bool?> _confirmExit() {
    if (_index == 0 && !_checked) return Future.value(true);
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quit quiz?'),
        content: const Text('Your progress on this quiz will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}

class _McqOptions extends StatelessWidget {
  final List<String> options;
  final int? selectedIndex;
  final int correctIndex;
  final bool showResult;
  final void Function(int)? onTap;

  const _McqOptions({
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          _OptionTile(
            label: options[i],
            letter: String.fromCharCode(65 + i),
            selected: selectedIndex == i,
            highlight: !showResult
                ? _OptionState.normal
                : (i == correctIndex
                    ? _OptionState.correct
                    : (selectedIndex == i
                        ? _OptionState.wrong
                        : _OptionState.normal)),
            onTap: onTap == null ? null : () => onTap!(i),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

enum _OptionState { normal, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String label;
  final String letter;
  final bool selected;
  final _OptionState highlight;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.label,
    required this.letter,
    required this.selected,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bg;
    Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    switch (highlight) {
      case _OptionState.correct:
        borderColor = AppColors.success;
        bg = AppColors.success.withOpacity(0.10);
        textColor = AppColors.success;
        break;
      case _OptionState.wrong:
        borderColor = AppColors.error;
        bg = AppColors.error.withOpacity(0.10);
        textColor = AppColors.error;
        break;
      case _OptionState.normal:
        borderColor =
            selected ? AppColors.primary : Theme.of(context).dividerColor;
        bg = selected
            ? AppColors.primary.withOpacity(0.06)
            : Theme.of(context).cardColor;
        textColor =
            Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.6),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MathText(
                label,
                fontSize: 15,
                color: textColor,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _InputBox({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Type your answer',
        prefixIcon: Icon(Icons.edit_rounded),
      ),
      style: Theme.of(context).textTheme.titleMedium,
      textInputAction: TextInputAction.done,
    );
  }
}

class _FeedbackBox extends StatelessWidget {
  final bool correct;
  final String solution;
  final String expected;

  const _FeedbackBox({
    required this.correct,
    required this.solution,
    required this.expected,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.success : AppColors.error;
    final title = correct ? 'Correct!' : 'Not quite.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (!correct && expected.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Expected:',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            MathText(expected, fontSize: 14, weight: FontWeight.w600),
          ],
          if (solution.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Solution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                    )),
            const SizedBox(height: 4),
            MathText(solution, fontSize: 14),
          ],
        ],
      ),
    );
  }
}
