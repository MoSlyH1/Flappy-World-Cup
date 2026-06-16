// lib/models/difficulty.dart
// Difficulty presets that tune gravity, pipe gap, speed and spawn rate.

import 'package:flutter/material.dart';

enum DifficultyLevel { easy, medium, hard }

class Difficulty {
  final DifficultyLevel level;
  final String label;
  final double gravity; // downward acceleration (px/s^2)
  final double jumpForce; // upward impulse on tap (negative velocity)
  final double pipeSpeed; // horizontal pipe speed (px/s)
  final double gapFraction; // vertical gap as fraction of screen height
  final double spawnInterval; // seconds between pipe pairs
  final Color color;

  const Difficulty({
    required this.level,
    required this.label,
    required this.gravity,
    required this.jumpForce,
    required this.pipeSpeed,
    required this.gapFraction,
    required this.spawnInterval,
    required this.color,
  });

  String get key => level.name; // 'easy' | 'medium' | 'hard'

  static const Difficulty easy = Difficulty(
    level: DifficultyLevel.easy,
    label: 'Easy',
    gravity: 900,
    jumpForce: -330,
    pipeSpeed: 150,
    gapFraction: 0.32,
    spawnInterval: 2.0,
    color: Color(0xFF4CAF50),
  );

  static const Difficulty medium = Difficulty(
    level: DifficultyLevel.medium,
    label: 'Medium',
    gravity: 1100,
    jumpForce: -360,
    pipeSpeed: 200,
    gapFraction: 0.26,
    spawnInterval: 1.6,
    color: Color(0xFFFF9800),
  );

  static const Difficulty hard = Difficulty(
    level: DifficultyLevel.hard,
    label: 'Hard',
    gravity: 1350,
    jumpForce: -390,
    pipeSpeed: 260,
    gapFraction: 0.22,
    spawnInterval: 1.3,
    color: Color(0xFFF44336),
  );

  static const List<Difficulty> all = [easy, medium, hard];

  static Difficulty fromKey(String key) {
    return all.firstWhere(
      (d) => d.key == key,
      orElse: () => easy,
    );
  }
}
