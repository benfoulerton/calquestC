import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// User-facing app settings: dark mode and sound effects.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  bool _darkMode = false;
  bool _soundOn = true;

  SettingsProvider({StorageService? storage})
      : _storage = storage ?? StorageService.instance;

  bool get darkMode => _darkMode;
  bool get soundOn => _soundOn;

  Future<void> load() async {
    _darkMode = await _storage.getDarkMode();
    _soundOn = await _storage.getSoundOn();
    notifyListeners();
  }

  Future<void> setDarkMode(bool v) async {
    _darkMode = v;
    await _storage.setDarkMode(v);
    notifyListeners();
  }

  Future<void> setSoundOn(bool v) async {
    _soundOn = v;
    await _storage.setSoundOn(v);
    notifyListeners();
  }
}
