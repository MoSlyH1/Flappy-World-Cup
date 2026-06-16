// lib/game/pipe.dart
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'flappy_game.dart';

class Pipe extends PositionComponent {
  final Color color; // body = team shirt colour
  final Color trim;  // stripe + accents

  Pipe({required Vector2 position, required Vector2 size,
        required this.color, required this.trim})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async => add(RectangleHitbox());

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, Paint()..color = color);                 // team body

    final stripeW = size.x * 0.22;                                 // kit stripe
    canvas.drawRect(Rect.fromLTWH(size.x / 2 - stripeW / 2, 0, stripeW, size.y),
        Paint()..color = trim);

    canvas.drawRect(rect, Paint()                                  // outline
      ..color = Colors.black.withOpacity(0.55)
      ..style = PaintingStyle.stroke..strokeWidth = 3);

    const capH = 20.0;                                             // checkered cap
    final capTop = position.y == 0 ? size.y - capH : 0.0;
    final sq = capH / 2;
    final cols = ((size.x + 8) / sq).ceil();
    for (var r = 0; r < 2; r++) {
      for (var c = 0; c < cols; c++) {
        final dark = ((r + c) % 2 == 0);
        canvas.drawRect(Rect.fromLTWH(-4 + c * sq, capTop + r * sq, sq, sq),
            Paint()..color = dark ? const Color(0xFF111111) : Colors.white);
      }
    }
  }
}

class PipePair extends PositionComponent with HasGameReference<FlappyGame> {
  static const double pipeWidth = 70;
  final double gapCenterY;
  final double gapHeight;
  bool scored = false;

  PipePair({required double startX, required this.gapCenterY, required this.gapHeight}) {
    position = Vector2(startX, 0);
    anchor = Anchor.topLeft;
  }

  @override
  Future<void> onLoad() async {
    final screenH = game.size.y;
    size = Vector2(pipeWidth, screenH);
    final topHeight = (gapCenterY - gapHeight / 2).clamp(0.0, screenH);
    final bottomY = gapCenterY + gapHeight / 2;
    final bottomHeight = (screenH - bottomY).clamp(0.0, screenH);

    final kit = game.currentPlayer; // colours for this round
    add(Pipe(position: Vector2.zero(), size: Vector2(pipeWidth, topHeight),
        color: kit.shirt, trim: kit.trim));
    add(Pipe(position: Vector2(0, bottomY), size: Vector2(pipeWidth, bottomHeight),
        color: kit.shirt, trim: kit.trim));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isPlaying) return;
    position.x -= game.difficulty.pipeSpeed * dt;
    if (position.x + pipeWidth < 0) removeFromParent();
  }
}