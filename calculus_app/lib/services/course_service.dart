import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/course.dart';

/// Loads the bundled `stewart_calculus_course.json` from `assets/data/`
/// and parses it into a [Course] object. Cached after first load.
class CourseService {
  CourseService._();
  static final instance = CourseService._();

  Course? _cache;

  Future<Course> loadCourse() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(
      'assets/data/stewart_calculus_course.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = Course.fromJson(json);
    return _cache!;
  }
}
