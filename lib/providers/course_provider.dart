import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../services/course_service.dart';

/// Exposes the parsed [Course] to the widget tree. One-shot load.
class CourseProvider extends ChangeNotifier {
  Course? _course;
  bool _loading = false;
  Object? _error;

  Course? get course => _course;
  bool get isLoading => _loading;
  Object? get error => _error;

  Future<void> load() async {
    if (_course != null || _loading) return;
    _loading = true;
    notifyListeners();
    try {
      _course = await CourseService.instance.loadCourse();
      _error = null;
    } catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
