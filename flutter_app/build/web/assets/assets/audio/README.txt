Drop your sound effect files here to enable audio:

  jump.wav    -> played on every tap/flap
  score.wav   -> played when you pass a pipe
  hit.wav     -> played on collision / game over

The game runs fine WITHOUT these files (it just stays silent), because
SoundService swallows missing-asset errors. Any short .wav files work —
you can grab free ones from sites like freesound.org or mixkit.co.

These filenames are already referenced in lib/services/sound_service.dart
and the assets/audio/ folder is registered in pubspec.yaml.
