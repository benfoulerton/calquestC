// lib/data/curriculum.dart
//
// Aggregates the in-Dart curriculum. Lessons are typed Dart objects (not
// JSON) so we can embed function references for animated diagrams.

import '../models/lesson.dart';
import 'unit_derivatives.dart';
import 'unit_functions.dart';
import 'unit_integrals.dart';

class Curriculum {
  Curriculum._();

  static final List<Unit> units = [
    unitFunctions,
    unitDerivatives,
    unitIntegrals,
  ];

  static List<Lesson> get allLessons =>
      units.expand((u) => u.lessons).toList();

  static Lesson? findById(String id) {
    for (final u in units) {
      for (final l in u.lessons) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  static int get totalLessons => allLessons.length;
}
