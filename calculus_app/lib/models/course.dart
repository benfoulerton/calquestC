/// Domain models for the Stewart Calculus course data.
///
/// The JSON shape (per `stewart_calculus_course.json`) is:
///   { course, units: [ { unit_number, title, topics: [ { title, lessons: [ Lesson ] } ] } ] }
/// Each [Lesson] has explanation, formulas, examples, common_mistakes, questions, answers, xp, difficulty.

class Course {
  final String name;
  final String description;
  final String source;
  final List<Unit> units;
  final int totalLessons;
  final int totalQuestions;
  final int totalXp;

  Course({
    required this.name,
    required this.description,
    required this.source,
    required this.units,
    required this.totalLessons,
    required this.totalQuestions,
    required this.totalXp,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final unitsJson = (json['units'] as List<dynamic>? ?? const []);
    return Course(
      name: json['course']?.toString() ?? 'Calculus',
      description: json['description']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      units: unitsJson
          .map((u) => Unit.fromJson(u as Map<String, dynamic>))
          .toList(),
      totalLessons: (json['total_lessons'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
    );
  }

  /// Flattens all lessons across units/topics for convenient indexing.
  List<Lesson> get allLessons {
    final out = <Lesson>[];
    for (final u in units) {
      for (final t in u.topics) {
        out.addAll(t.lessons);
      }
    }
    return out;
  }
}

class Unit {
  final int unitNumber;
  final String title;
  final List<Topic> topics;

  Unit({required this.unitNumber, required this.title, required this.topics});

  factory Unit.fromJson(Map<String, dynamic> json) {
    final topicsJson = (json['topics'] as List<dynamic>? ?? const []);
    return Unit(
      unitNumber: (json['unit_number'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? 'Untitled Unit',
      topics: topicsJson
          .map((t) => Topic.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  List<Lesson> get lessons => topics.expand((t) => t.lessons).toList();
}

class Topic {
  final String title;
  final List<Lesson> lessons;

  Topic({required this.title, required this.lessons});

  factory Topic.fromJson(Map<String, dynamic> json) {
    final lessonsJson = (json['lessons'] as List<dynamic>? ?? const []);
    return Topic(
      title: json['title']?.toString() ?? '',
      lessons: lessonsJson
          .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Lesson {
  final String title;
  final String explanation;
  final List<String> formulas;
  final List<WorkedExample> examples;
  final List<String> commonMistakes;
  final List<Question> questions;
  final List<String> answers;
  final int xp;
  final int difficulty;

  Lesson({
    required this.title,
    required this.explanation,
    required this.formulas,
    required this.examples,
    required this.commonMistakes,
    required this.questions,
    required this.answers,
    required this.xp,
    required this.difficulty,
  });

  /// Stable string id used to key progress in shared_preferences.
  String get id => title;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      title: json['title']?.toString() ?? 'Lesson',
      explanation: json['explanation']?.toString() ?? '',
      formulas: _stringList(json['formulas']),
      examples: ((json['examples'] as List<dynamic>?) ?? const [])
          .map((e) => WorkedExample.fromJson(e as Map<String, dynamic>))
          .toList(),
      commonMistakes: _stringList(json['common_mistakes']),
      questions: ((json['questions'] as List<dynamic>?) ?? const [])
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      answers: _stringList(json['answers']),
      xp: (json['xp'] as num?)?.toInt() ?? 10,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
    );
  }
}

class WorkedExample {
  final String setup;
  final List<String> steps;
  final String result;

  WorkedExample({required this.setup, required this.steps, required this.result});

  factory WorkedExample.fromJson(Map<String, dynamic> json) {
    return WorkedExample(
      setup: json['setup']?.toString() ?? '',
      steps: _stringList(json['steps']),
      result: json['result']?.toString() ?? '',
    );
  }
}

enum QuestionKind { multipleChoice, input }

class Question {
  final QuestionKind kind;
  final String prompt;
  final List<String> options;       // for MCQ
  final int correctIndex;            // for MCQ
  final String correctAnswer;        // for input
  final String solution;             // explanation shown after answering

  Question({
    required this.kind,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.correctAnswer,
    required this.solution,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? '';
    final isMcq = type == 'mcq' || json.containsKey('options');
    return Question(
      kind: isMcq ? QuestionKind.multipleChoice : QuestionKind.input,
      prompt: json['prompt']?.toString() ?? '',
      options: _stringList(json['options']),
      correctIndex: (json['correct_index'] as num?)?.toInt() ?? 0,
      correctAnswer: json['answer']?.toString() ?? '',
      solution: json['solution']?.toString() ?? json['explanation']?.toString() ?? '',
    );
  }
}

List<String> _stringList(dynamic raw) {
  if (raw is List) return raw.map((e) => e.toString()).toList();
  return const [];
}
