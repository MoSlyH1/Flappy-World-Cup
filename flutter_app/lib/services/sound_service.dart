// lib/services/sound_service.dart
// Thin wrapper around flame_audio. If audio files are missing the calls
// fail silently so the game still runs without any assets.
//
// To enable sound, drop these files into assets/audio/ :
//   jump.wav   score.wav   hit.wav
// (they are already declared in pubspec.yaml under assets/audio/)

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static bool enabled = true;
  static bool _warmed = false;

  static Future<void> preload() async {
    if (!enabled || _warmed) return;
    _warmed = true;
    try {
      await FlameAudio.audioCache.loadAll(['jump.wav', 'score.wav', 'hit.wav']);
    } catch (_) {
      // Assets not present yet — that's fine, game runs silent.
    }
  }

  static void _play(String file) {
    if (!enabled) return;
    try {
      FlameAudio.play(file);
    } catch (e) {
      if (kDebugMode) debugPrint('Sound "$file" not played: $e');
    }
  }

  static void jump() => _play('jump.wav');
  static void score() => _play('score.wav');
  static void hit() => _play('hit.wav');
}
