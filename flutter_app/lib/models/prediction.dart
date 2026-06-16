// lib/models/prediction.dart

class PredictionStat {
  final String team;
  final int votes;
  final double percentage;

  const PredictionStat({
    required this.team,
    required this.votes,
    required this.percentage,
  });

  factory PredictionStat.fromJson(Map<String, dynamic> json) {
    return PredictionStat(
      team: json['team'] as String? ?? 'Unknown',
      votes: json['votes'] is int
          ? json['votes'] as int
          : int.tryParse('${json['votes']}') ?? 0,
      percentage: (json['percentage'] is num)
          ? (json['percentage'] as num).toDouble()
          : double.tryParse('${json['percentage']}') ?? 0,
    );
  }
}
