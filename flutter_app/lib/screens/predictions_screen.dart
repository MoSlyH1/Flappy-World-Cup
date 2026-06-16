// lib/screens/predictions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/world_cup_teams.dart';
import '../models/prediction.dart';
import '../providers/prediction_provider.dart';
import '../widgets/flag_widget.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PredictionProvider>().loadStats(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Who Will Win? 🏆'),
        backgroundColor: const Color(0xFF0B6E4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.loadStats(),
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PredictionProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(provider.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => provider.loadStats(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.stats.isEmpty) {
      return const Center(child: Text('No predictions yet. Cast your vote!'));
    }

    final maxVotes = provider.stats
        .map((s) => s.votes)
        .fold<int>(1, (a, b) => a > b ? a : b);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF0B6E4F),
          child: Column(
            children: [
              Text('${provider.total} total predictions',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              if (provider.myPick != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Your pick: ${provider.myPick}',
                      style: const TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.stats.length,
            itemBuilder: (_, i) =>
                _statRow(provider.stats[i], i + 1, maxVotes),
          ),
        ),
      ],
    );
  }

  Widget _statRow(PredictionStat stat, int rank, int maxVotes) {
    final country = WorldCup.byName(stat.team);
    final fraction = (stat.votes / maxVotes).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('$rank',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          if (country != null)
            FlagWidget(country: country, width: 30, height: 20)
          else
            const Icon(Icons.flag, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        country?.isBonus == true ? '${stat.team} ⭐' : stat.team,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text('${stat.votes} · ${stat.percentage}%',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                    backgroundColor: Colors.black12,
                    color: country?.colors.first ?? const Color(0xFF13A36B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
