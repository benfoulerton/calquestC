// lib/widgets/questions/question_result.dart
//
// Every question widget exposes one callback: onAnswered(correct, hint).
// The runner consumes it to schedule progress updates and feedback.

typedef QuestionAnsweredCallback = void Function(bool correct, String? hint);
