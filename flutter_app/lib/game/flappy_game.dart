// lib/game/flappy_game.dart
import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../data/football_players.dart';
import '../models/difficulty.dart';
import '../services/sound_service.dart';
import 'bird.dart';
import 'pipe.dart';
import 'scenery.dart';

class FlappyGame extends FlameGame with HasCollisionDetection {
  FlappyGame({
    required this.difficulty,
    required this.onScoreChanged,
    required this.onGameOverCb,
    this.onPlayerChanged,
  });

  Difficulty difficulty;
  final void Function(int score) onScoreChanged;
  final void Function(int finalScore) onGameOverCb;
  final void Function(FootballPlayer player)? onPlayerChanged;

  late final Bird bird;

  // The footballer used as the bird for the current round.
  FootballPlayer currentPlayer = Players.all.first;

  int score = 0;
  bool isPlaying = false;
  bool isGameOver = false;

  double _spawnTimer = 0;
  final math.Random _rng = math.Random();

  void _pickPlayer() {
    currentPlayer = Players.all[_rng.nextInt(Players.all.length)];
    onPlayerChanged?.call(currentPlayer);
  }

  @override
  Future<void> onLoad() async {
    await add(Background());
    await add(Ground());
    bird = Bird();
    await add(bird);
    _pickPlayer();
    _placeBirdAtStart();
  }

  void _placeBirdAtStart() {
    bird.reset(Vector2(size.x * 0.28, size.y * 0.45));
  }

  /// Begin (or restart) a run.
  void start() {
    for (final pair in children.whereType<PipePair>().toList()) {
      pair.removeFromParent();
    }
    _pickPlayer(); // new footballer every round
    score = 0;
    onScoreChanged(score);
    _spawnTimer = 0;
    isGameOver = false;
    _placeBirdAtStart();
    isPlaying = true;
  }

  /// Called from the UI on every tap.
  void onTapJump() {
    if (isGameOver) return;
    if (!isPlaying) start();
    bird.jump();
    SoundService.jump();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    _spawnTimer += dt;
    if (_spawnTimer >= difficulty.spawnInterval) {
      _spawnTimer = 0;
      _spawnPipe();
    }

    // Award a point once the bird fully clears a pipe pair.
    for (final pair in children.whereType<PipePair>()) {
      if (!pair.scored &&
          pair.position.x + PipePair.pipeWidth < bird.position.x) {
        pair.scored = true;
        score++;
        onScoreChanged(score);
        SoundService.score();
      }
    }
  }

  void _spawnPipe() {
    final gapHeight = size.y * difficulty.gapFraction;
    final minCenter = gapHeight / 2 + 50;
    final maxCenter =
        size.y - Ground.groundHeight - gapHeight / 2 - 20;
    final center = minCenter + _rng.nextDouble() * (maxCenter - minCenter);

    add(PipePair(
      startX: size.x + 30,
      gapCenterY: center,
      gapHeight: gapHeight,
    ));
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    isPlaying = false;
    SoundService.hit();
    onGameOverCb(score);
  }
}
