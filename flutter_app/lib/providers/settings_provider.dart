// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import '../models/difficulty.dart';
import '../services/api_service.dart';
import '../services/prefs_service.dart';

/// Holds app-wide settings: the player's username (entered at the start),
/// the chosen difficulty, and the backend server URL (handy on a phone).
class SettingsProvider extends ChangeNotifier {
  Difficulty _difficulty = Difficulty.easy;
  String _username = PrefsService.username;

  Difficulty get difficulty => _difficulty;
  String get username => _username;
  bool get hasUsername => _username.trim().isNotEmpty;

  /// Current effective backend address (override or platform default).
  String get serverUrl => ApiService.baseUrl;

  void setDifficulty(Difficulty d) {
    _difficulty = d;
    notifyListeners();
  }

  void setUsername(String name) {
    _username = name.trim();
    PrefsService.setUsername(_username);
    notifyListeners();
  }

  /// Point the app at a different backend (e.g. your PC's LAN IP on a phone).
  /// Pass null/empty to fall back to the platform default.
  void setServerUrl(String? url) {
    ApiService.customBaseUrl = (url == null || url.trim().isEmpty) ? null : url.trim();
    PrefsService.setServerUrl(ApiService.customBaseUrl);
    notifyListeners();
  }
}
