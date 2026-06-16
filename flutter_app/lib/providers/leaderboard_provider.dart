// lib/providers/leaderboard_provider.dart
import 'package:flutter/foundation.dart';
import '../models/score.dart';
import '../services/api_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Score> scores = [];
  bool loading = false;
  String? error;

  /// Load the global leaderboard from the backend.
  Future<void> load({String? difficulty, int limit = 20}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      scores = await _api.fetchLeaderboard(
        difficulty: difficulty,
        limit: limit,
      );
    } catch (e) {
      error = 'Could not reach the leaderboard server.\n'
          'Is the backend running on port 4000?';
      scores = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Submit a score to the global leaderboard.
  /// Returns true on success.
  Future<bool> submit(Score score) async {
    try {
      await _api.submitScore(score);
      return true;
    } catch (e) {
      error = 'Failed to submit score. Check the backend connection.';
      notifyListeners();
      return false;
    }
  }
}
