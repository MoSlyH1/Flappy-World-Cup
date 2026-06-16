// lib/screens/game_screen.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/football_players.dart';
import '../data/world_cup_teams.dart';
import '../game/flappy_game.dart';
import '../models/difficulty.dart';
import '../models/score.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/settings_provider.dart';
import '../services/local_db_service.dart';
import '../services/sound_service.dart';
import '../widgets/flag_widget.dart';
import 'leaderboard_screen.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final FlappyGame _game;
  FootballPlayer _player = Players.all.first;
  int _score = 0;
  bool _started = false;
  bool _gameOver = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    SoundService.preload();
    _game = FlappyGame(
      difficulty: widget.difficulty,
      onScoreChanged: (s) {
        if (mounted) setState(() => _score = s);
      },
      onGameOverCb: _handleGameOver,
      onPlayerChanged: (p) {
        if (mounted) setState(() => _player = p);
      },
    );
  }

Future<void> _handleGameOver(int finalScore) async {
  final settings = context.read<SettingsProvider>();
  final leaderboard = context.read<LeaderboardProvider>(); // before await
  final score = Score(
    playerName: settings.username,
    score: finalScore,
    difficulty: widget.difficulty.key,
  );
  await LocalDbService.instance.saveScore(score); // local copy
  final ok = await leaderboard.submit(score);     // -> Postgres, automatically
  if (mounted) setState(() { _gameOver = true; _submitted = ok; });
}

  void _onTap() {
    if (_gameOver) return;
    setState(() => _started = true);
    _game.onTapJump();
  }

  void _restart() {
    setState(() {
      _gameOver = false;
      _submitted = false;
      _started = true;
      _score = 0;
    });
    _game.start();
  }

  Future<void> _submitToLeaderboard() async {
    final settings = context.read<SettingsProvider>();
    final provider = context.read<LeaderboardProvider>();
    final ok = await provider.submit(
      Score(
        playerName: settings.username,
        score: _score,
        difficulty: widget.difficulty.key,
      ),
    );
    if (!mounted) return;
    setState(() => _submitted = ok);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Score submitted to the global leaderboard!'
            : 'Could not submit. Is the backend running?'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final country = WorldCup.byName(_player.country);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTap,
            child: GameWidget(game: _game),
          ),

          // "Playing as" banner (current footballer + flag).
          Positioned(
            top: 44,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (country != null)
                        FlagWidget(country: country, width: 24, height: 16),
                      const SizedBox(width: 8),
                      Text('Playing as ${_player.name}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Live score.
          if (_started && !_gameOver)
            Positioned(
              top: 96,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '$_score',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              ),
            ),

          // Tap-to-start hint.
          if (!_started && !_gameOver)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app, size: 60, color: Colors.white),
                      SizedBox(height: 8),
                      Text('Tap to start',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

          // Back button.
          Positioned(
            top: 40,
            left: 8,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          if (_gameOver) _buildGameOverPanel(country),
        ],
      ),
    );
  }

  Widget _buildGameOverPanel(Country? country) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Full Time! ⚽',
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (country != null)
                      FlagWidget(country: country, width: 24, height: 16),
                    const SizedBox(width: 6),
                    Text(_player.name,
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Score: $_score',
                    style: const TextStyle(fontSize: 22)),
                Text('Difficulty: ${widget.difficulty.label}',
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: _restart,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _submitted ? null : _submitToLeaderboard,
                      icon: const Icon(Icons.cloud_upload),
                      label: Text(_submitted ? 'Submitted' : 'Submit'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LeaderboardScreen()),
                  ),
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('View Leaderboard'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
