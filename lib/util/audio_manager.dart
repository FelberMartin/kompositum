import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {

  static AudioManager? _instance;
  static AudioManager get instance {
    _instance ??= AudioManager._();
    return _instance!;
  }

  AudioManager._() {

  }

  var isMuted = false;

  void toggleMute() {
    isMuted = !isMuted;
  }

  // - button click
  // - star collected
  // - compound found?
  // - compound incorrect
  // - last compound found? (vibrate)

  void playButtonClicked() {
    if (isMuted) return;
    SystemSound.play(SystemSoundType.click);
  }

  void playStarCollected() {
    _playAsset("score.mp3");
  }

  void playLevelComplete() {
    _playAsset("success_02.wav", volume: 0.3);
  }

  void playHint() {
    _playAsset("hint.wav");
  }

  void playCompoundFound() {
    _playAsset("correct.wav", volume: 0.15);
  }

  void playCompoundIncorrect() {
    _playAsset("incorrect.wav", volume: 0.3);
  }

  void _playAsset(String asset, {double volume = 0.4}) async {
    if (isMuted) return;
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);
    await player.setSource(AssetSource("sounds/$asset"));
    await player.setVolume(volume);
    await player.resume();
  }

}