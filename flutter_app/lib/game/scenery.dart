// lib/game/scenery.dart
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'flappy_game.dart';

/// Solid ground at the bottom. Collidable — touching it ends the run.
class Ground extends PositionComponent with HasGameReference<FlappyGame> {
  static const double groundHeight = 44;

  @override
  Future<void> onLoad() async {
    _resize(game.size);
    add(RectangleHitbox());
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    _resize(newSize);
  }

  void _resize(Vector2 gameSize) {
    size = Vector2(gameSize.x, groundHeight);
    position = Vector2(0, gameSize.y - groundHeight);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF8D6E63));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 6),
      Paint()..color = const Color(0xFF7CB342),
    );
  }
}

/// Sky gradient background, drawn behind everything.
class Background extends PositionComponent with HasGameReference<FlappyGame> {
  Background() {
    priority = -10;
  }

  @override
  Future<void> onLoad() async {
    size = game.size;
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    size = newSize;
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4EC0CA), Color(0xFFB8ECF3)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
