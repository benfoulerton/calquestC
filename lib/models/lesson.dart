// lib/models/lesson.dart
//
// Lessons aggregate MicroScreens into a single ~3-5 minute experience.
// Units group lessons by topic. The whole curriculum is a list of units.

import 'micro_screen.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screens,
    this.xpReward = 12,
  });

  final String id;
  final String title;
  final String subtitle;
  /// A short emoji or single-character symbol for the path-map node.
  final String icon;
  final List<MicroScreen> screens;
  final int xpReward;

  /// How many of the screens are graded questions. Drives the segmented
  /// progress bar denominator.
  int get questionCount => screens.where((s) => s.isQuestion).length;
}

class Unit {
  const Unit({
    required this.id,
    required this.title,
    required this.tagline,
    required this.icon,
    required this.lessons,
  });

  final String id;
  final String title;
  final String tagline;
  final String icon;
  final List<Lesson> lessons;
}
