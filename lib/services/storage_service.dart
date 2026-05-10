// lib/services/storage_service.dart
//
// Thin wrapper around SharedPreferences. Single source of truth for
// progress persistence.

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  static const _kProgress = 'progress.v2';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<UserProgress> loadProgress() async {
    final p = await _p;
    final raw = p.getString(_kProgress);
    if (raw == null) return UserProgress();
    try {
      return UserProgress.fromJsonString(raw);
    } catch (_) {
      return UserProgress();
    }
  }

  Future<void> saveProgress(UserProgress prog) async {
    final p = await _p;
    await p.setString(_kProgress, prog.toJsonString());
  }

  Future<void> reset() async {
    final p = await _p;
    await p.remove(_kProgress);
  }
}
