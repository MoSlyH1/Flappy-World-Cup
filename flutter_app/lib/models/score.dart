// lib/models/score.dart
// Data model for a single leaderboard entry.

class Score {
  final int? id;
  final String playerName;
  final int score;
  final String difficulty;
  final DateTime? createdAt;

  const Score({
    this.id,
    required this.playerName,
    required this.score,
    required this.difficulty,
    this.createdAt,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}'),
      playerName: json['player_name'] as String? ?? 'Unknown',
      score: json['score'] is int
          ? json['score'] as int
          : int.tryParse('${json['score']}') ?? 0,
      difficulty: json['difficulty'] as String? ?? 'easy',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'player_name': playerName,
        'score': score,
        'difficulty': difficulty,
      };

  // For the local SQLite high-score table.
  Map<String, dynamic> toLocalMap() => {
        'player_name': playerName,
        'score': score,
        'difficulty': difficulty,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory Score.fromLocalMap(Map<String, dynamic> map) {
    return Score(
      id: map['id'] as int?,
      playerName: map['player_name'] as String? ?? 'You',
      score: map['score'] as int? ?? 0,
      difficulty: map['difficulty'] as String? ?? 'easy',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse('${map['created_at']}')
          : null,
    );
  }
}
