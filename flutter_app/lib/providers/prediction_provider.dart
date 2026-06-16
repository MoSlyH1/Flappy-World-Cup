// lib/providers/prediction_provider.dart
import 'package:flutter/foundation.dart';
import '../models/prediction.dart';
import '../services/api_service.dart';

class PredictionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  String? myPick; // the team this user voted for
  int total = 0;
  List<PredictionStat> stats = [];
  bool loading = false;
  bool submitting = false;
  String? error;

  Future<void> loadStats() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _api.fetchPredictionStats();
      total = res.total;
      stats = res.stats;
    } catch (e) {
      error = 'Could not load predictions.\nIs the backend running on port 4000?';
      stats = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> vote({required String username, required String team}) async {
    submitting = true;
    error = null;
    notifyListeners();
    try {
      await _api.submitPrediction(username: username, team: team);
      myPick = team;
      await loadStats();
      return true;
    } catch (e) {
      error = 'Could not submit your prediction.';
      submitting = false;
      notifyListeners();
      return false;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
