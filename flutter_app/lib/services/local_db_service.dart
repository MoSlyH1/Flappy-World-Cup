// lib/services/local_db_service.dart
// Stores local high scores in SQLite on mobile/desktop.
//
// NOTE: the `sqflite` package does NOT support Flutter web. To keep the
// game web-playable, we detect `kIsWeb` and fall back to a simple
// in-memory list (scores last only for the session on web). On mobile
// the scores persist on the device as requested.

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/score.dart';

class LocalDbService {
  static final LocalDbService instance = LocalDbService._();
  LocalDbService._();

  Database? _db;

  // In-memory fallback used on web.
  final List<Score> _webScores = [];

  Future<Database> _getDb() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'flappy_scores.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE high_scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            player_name TEXT NOT NULL,
            score INTEGER NOT NULL,
            difficulty TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  /// Save a score locally.
  Future<void> saveScore(Score score) async {
    if (kIsWeb) {
      _webScores.add(score);
      _webScores.sort((a, b) => b.score.compareTo(a.score));
      return;
    }
    final db = await _getDb();
    await db.insert('high_scores', score.toLocalMap());
  }

  /// Top local scores (optionally filtered by difficulty).
  Future<List<Score>> getTopScores({String? difficulty, int limit = 10}) async {
    if (kIsWeb) {
      final filtered = difficulty == null
          ? _webScores
          : _webScores.where((s) => s.difficulty == difficulty).toList();
      return filtered.take(limit).toList();
    }

    final db = await _getDb();
    final rows = await db.query(
      'high_scores',
      where: difficulty != null ? 'difficulty = ?' : null,
      whereArgs: difficulty != null ? [difficulty] : null,
      orderBy: 'score DESC, created_at ASC',
      limit: limit,
    );
    return rows.map(Score.fromLocalMap).toList();
  }

  /// The single best local score (used to show "best" on the menu).
  Future<int> getBestScore({String? difficulty}) async {
    final top = await getTopScores(difficulty: difficulty, limit: 1);
    return top.isEmpty ? 0 : top.first.score;
  }
}
