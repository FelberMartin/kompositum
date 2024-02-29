import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../config/my_theme.dart';

class AudioManager {

  static AudioManager? _instance;
  static AudioManager get instance {
    _instance ??= AudioManager._();
    return _instance!;
  }

  AudioManager._();

  var isMuted = false;
  final _playersByAsset = <String, AudioPlayer>{};

  void toggleMute() {
    isMuted = !isMuted;
  }

  void playButtonClicked() {
    _playAsset("tap.wav", volume: 0.2);
  }

  void playStarCollected() {
    _playAsset("score.wav", volume: 0.4);
  }

  void playLevelComplete() {
    _playAsset("success_02.wav");
  }

  void playHint() {
    _playAsset("hint.wav");
  }

  void playCompoundFound() {
    _playAsset("correct.wav", volume: 0.2);
  }

  void playCompoundIncorrect() {
    _playAsset("incorrect.wav");
  }

  void _playAsset(String asset, {double volume = 0.3}) async {
    if (isMuted) return;

    if (_playersByAsset.containsKey(asset)) {
      _playersByAsset[asset]!.stop();
    } else {
      final player = AudioPlayer();
      player.setPlayerMode(PlayerMode.lowLatency);
      await player.setSource(AssetSource("sounds/$asset"));
      await player.setVolume(volume);
      await player.setReleaseMode(ReleaseMode.stop);
      _playersByAsset[asset] = player;
    }

    await _playersByAsset[asset]!.resume();
  }

  void playEasterEgg(EasterEgg easterEgg) {
    _playAsset(easterEgg.asset);
  }

  void dispose() {
    for (final player in _playersByAsset.values) {
      player.dispose();
    }
    _playersByAsset.clear();
  }
}

enum EasterEgg {
  Orangensaft("Orangensaft", "orangensaft.wav"),
  Apfelsaft("Apfelsaft", "apfelsaft.wav");

  final String compound;
  final String asset;
  const EasterEgg(this.compound, this.asset);
}

void main() {
  runApp(MaterialApp(
      theme: myTheme,
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playCompoundFound();
            },
            child: Text("Compound found"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playCompoundIncorrect();
            },
            child: Text("Compound incorrect"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playStarCollected();
            },
            child: Text("Star collected"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playButtonClicked();
            },
            child: Text("Button clicked"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playLevelComplete();
            },
            child: Text("Level complete"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playHint();
            },
            child: Text("Hint"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playEasterEgg(EasterEgg.Orangensaft);
            },
            child: Text("Orangensaft"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playEasterEgg(EasterEgg.Apfelsaft);
            },
            child: Text("Apfelsaft"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.toggleMute();
            },
            child: Column(
              children: [
                Text("Toggle mute"),
                Icon(AudioManager.instance.isMuted ? Icons.volume_off : Icons.volume_up),
              ],
            ),
          ),
        ],
      )));
}