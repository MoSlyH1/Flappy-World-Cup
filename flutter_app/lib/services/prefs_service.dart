// lib/services/prefs_service.dart
// Tiny wrapper around SharedPreferences so the phone remembers the
// username and the backend "Server URL" between launches.

import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static SharedPreferences? _p;

  static const _kUsername = 'username';
  static const _kServerUrl = 'serverUrl';

  /// Call once in main() before runApp().
  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static String get username => _p?.getString(_kUsername) ?? '';
  static Future<void> setUsername(String v) async {
    await _p?.setString(_kUsername, v);
  }

  static String? get serverUrl => _p?.getString(_kServerUrl);
  static Future<void> setServerUrl(String? v) async {
    if (v == null || v.trim().isEmpty) {
      await _p?.remove(_kServerUrl);
    } else {
      await _p?.setString(_kServerUrl, v.trim());
    }
  }
}
