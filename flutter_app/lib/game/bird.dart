// lib/game/bird.dart
// The bird is styled as the current round's football "star": its body
// is the team jersey colour, with a little head + hair, a flapping wing,
// and a chest trim stripe.

import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'flappy_game.dart';

class Bird extends PositionComponent
    with HasGameReference<FlappyGame>, CollisionCallbacks {
  static const double radius = 18;
  double velocity = 0;
  double _flapT = 0;

  Bird()
      : super(
          size: Vector2.all(radius * 2),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  void jump() {
    velocity = game.difficulty.jumpForce;
  }

  void reset(Vector2 startPos) {
    velocity = 0;
    position = startPos;
    angle = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _flapT += dt * 12;
    if (!game.isPlaying) return;

    velocity += game.difficulty.gravity * dt;
    position.y += velocity * dt;
    angle = (velocity / 600).clamp(-0.5, 1.2);

    if (position.y - radius <= 0) {
      position.y = radius;
      velocity = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    final player = game.currentPlayer;
    final c = Offset(size.x / 2, size.y / 2);

    // Wing (drawn behind body), flaps up and down.
    final wingY = math.sin(_flapT) * 4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx - 6, c.dy + 2 + wingY),
        width: 18,
        height: 12,
      ),
      Paint()..color = player.trim,
    );

    // Body
    canvas.drawCircle(c, radius, Paint()..color = player.shirt);
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Chest trim stripe
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: radius)));
    canvas.drawRect(
      Rect.fromLTWH(c.dx - radius, c.dy - 3, radius * 2, 6),
      Paint()..color = player.trim,
    );
    canvas.restore();

    // Head (skin) sitting up-front
    final head = Offset(c.dx + 7, c.dy - radius + 4);
    canvas.drawCircle(head, 9, Paint()..color = player.skin);
    // Hair (arc on top of head)
    canvas.drawArc(
      Rect.fromCircle(center: head, radius: 9),
      math.pi,
      math.pi,
      true,
      Paint()..color = player.hair,
    );
    // Eye
    canvas.drawCircle(Offset(head.dx + 3, head.dy), 2.4, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(head.dx + 3.6, head.dy), 1.2, Paint()..color = Colors.black);
    // Beak
    final beak = Path()
      ..moveTo(head.dx + 7, head.dy - 1)
      ..lineTo(head.dx + 14, head.dy + 1)
      ..lineTo(head.dx + 7, head.dy + 3)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFF7043));
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    // Pipes and the ground are the only hitboxes, so any hit ends the run.
    game.gameOver();
  }
}
