import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

/// Thin wrapper around [SharedPreferences] for app settings and user progress.
class StorageService {
  StorageService._();
  static final instance = StorageService._();

  static const _kProgress = 'progress.v1';
  static const _kDarkMode = 'settings.darkMode';
  static const _kSoundOn = 'settings.soundOn';
  static const _kIntroShown = 'settings.introShown';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ----- Progress -----

  Future<UserProgress> loadProgress() async {
    final p = await _p;
    final s = p.getString(_kProgress);
    if (s == null) return UserProgress();
    try {
      return UserProgress.fromJsonString(s);
    } catch (_) {
      return UserProgress();
    }
  }

  Future<void> saveProgress(UserProgress prog) async {
    final p = await _p;
    await p.setString(_kProgress, prog.toJsonString());
  }

  Future<void> resetProgress() async {
    final p = await _p;
    await p.remove(_kProgress);
  }

  // ----- Settings -----

  Future<bool> getDarkMode() async {
    final p = await _p;
    return p.getBool(_kDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool v) async {
    final p = await _p;
    await p.setBool(_kDarkMode, v);
  }

  Future<bool> getSoundOn() async {
    final p = await _p;
    return p.getBool(_kSoundOn) ?? true;
  }

  Future<void> setSoundOn(bool v) async {
    final p = await _p;
    await p.setBool(_kSoundOn, v);
  }

  Future<bool> getIntroShown() async {
    final p = await _p;
    return p.getBool(_kIntroShown) ?? false;
  }

  Future<void> setIntroShown(bool v) async {
    final p = await _p;
    await p.setBool(_kIntroShown, v);
  }
}
