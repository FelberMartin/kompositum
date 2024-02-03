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
    _playAsset("star2.mp3");
  }

  void _playAsset(String asset) async {
    if (isMuted) return;
    final player = AudioPlayer();
    player.setPlayerMode(PlayerMode.lowLatency);
    await player.setSource(AssetSource("sounds/$asset"));
    await player.setVolume(0.3);
    await player.resume();
  }

}