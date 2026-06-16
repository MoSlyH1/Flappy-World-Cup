// lib/services/api_service.dart
// Talks to the Express backend (POST /api/scores, GET /api/leaderboard).

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/score.dart';
import '../models/prediction.dart';

class ApiService {
  // ---------------------------------------------------------------
  // Base URL selection (first match wins):
  //
  //  1. customBaseUrl   -> set at runtime from the in-app "Server URL"
  //                        field (persisted), best for a PHYSICAL phone.
  //  2. --dart-define=API_BASE_URL=http://192.168.1.20:4000
  //  3. Platform default:
  //       Web / iOS simulator / desktop : http://localhost:4000
  //       Android emulator              : http://10.0.2.2:4000
  //
  // On a real phone, localhost/10.0.2.2 point at the phone itself, so you
  // MUST use your computer's LAN IP (e.g. http://192.168.1.20:4000) via
  // option 1 or 2. Find it with `ipconfig` (Windows) / `ifconfig` (mac/Linux).
  // ---------------------------------------------------------------

  /// Set this to override the backend address at runtime (in-app field).
  static String? customBaseUrl;

  /// Optional compile-time override: flutter run --dart-define=API_BASE_URL=...
  static const String _envBase = String.fromEnvironment('API_BASE_URL');

  /// The address used if nothing is overridden.
  static String get defaultBaseUrl {
    if (_envBase.isNotEmpty) return _envBase;
    if (kIsWeb) return 'http://localhost:4000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000';
    }
    return 'http://localhost:4000';
  }

  static String get baseUrl {
    final c = customBaseUrl;
    if (c != null && c.trim().isNotEmpty) return c.trim();
    return defaultBaseUrl;
  }

  static const Duration _timeout = Duration(seconds: 8);

  /// GET /api/leaderboard?difficulty=&limit=
  Future<List<Score>> fetchLeaderboard({
    String? difficulty,
    int limit = 10,
  }) async {
    final query = <String, String>{'limit': '$limit'};
    if (difficulty != null) query['difficulty'] = difficulty;

    final uri = Uri.parse('$baseUrl/api/leaderboard')
        .replace(queryParameters: query);

    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Leaderboard request failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final rows = (body['data'] as List<dynamic>? ?? []);
    return rows
        .map((e) => Score.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/scores
  Future<Score> submitScore(Score score) async {
    final uri = Uri.parse('$baseUrl/api/scores');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(score.toJson()),
        )
        .timeout(_timeout);

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Submit score failed (${res.statusCode})');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return Score.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// POST /api/predictions  — vote for the World Cup winner.
  Future<void> submitPrediction({
    required String username,
    required String team,
  }) async {
    final uri = Uri.parse('$baseUrl/api/predictions');
    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'team': team}),
        )
        .timeout(_timeout);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Submit prediction failed (${res.statusCode})');
    }
  }

  /// GET /api/predictions/stats — returns (total, sorted stats).
  Future<({int total, List<PredictionStat> stats})> fetchPredictionStats() async {
    final uri = Uri.parse('$baseUrl/api/predictions/stats');
    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Prediction stats failed (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final total = (body['total'] as num?)?.toInt() ?? 0;
    final rows = (body['data'] as List<dynamic>? ?? []);
    final stats = rows
        .map((e) => PredictionStat.fromJson(e as Map<String, dynamic>))
        .toList();
    return (total: total, stats: stats);
  }
}
