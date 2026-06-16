// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/difficulty.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String? _filter; // null = all difficulties

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() =>
      context.read<LeaderboardProvider>().load(difficulty: _filter);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Difficulty filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) {
                    setState(() => _filter = null);
                    _load();
                  },
                ),
                ...Difficulty.all.map((d) => ChoiceChip(
                      label: Text(d.label),
                      selected: _filter == d.key,
                      selectedColor: d.color,
                      onSelected: (_) {
                        setState(() => _filter = d.key);
                        _load();
                      },
                    )),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(LeaderboardProvider provider) {
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
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (provider.scores.isEmpty) {
      return const Center(child: Text('No scores yet. Be the first!'));
    }

    return ListView.separated(
      itemCount: provider.scores.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = provider.scores[i];
        final rank = i + 1;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _rankColor(rank),
            child: Text('$rank',
                style: const TextStyle(color: Colors.white)),
          ),
          title: Text(s.playerName,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(Difficulty.fromKey(s.difficulty).label),
          trailing: Text('${s.score}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFC107);
      case 2:
        return const Color(0xFF90A4AE);
      case 3:
        return const Color(0xFF8D6E63);
      default:
        return const Color(0xFF42A5F5);
    }
  }
}
