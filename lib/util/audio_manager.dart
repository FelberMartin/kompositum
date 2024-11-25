import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../config/my_theme.dart';
import '../data/key_value_store.dart';
import '../game/game_event/game_event.dart';

class AudioManager {

  static AudioManager? _instance;
  static AudioManager get instance {
    _instance ??= AudioManager._();
    return _instance!;
  }

  AudioManager._();

  var _isMuted = false;
  bool get isMuted => _isMuted;
  final _playersByAsset = <String, AudioPlayer>{};
  StreamSubscription? _gameEventStreamSubscription;
  KeyValueStore? _keyValueStore;

  void registerKeyValueStore(KeyValueStore keyValueStore) async {
    _keyValueStore = keyValueStore;
    _isMuted = await keyValueStore.getBooleanSetting(BooleanSetting.isAudioMuted);
  }

  void registerGameEventStream(Stream<GameEvent> gameEventStream) {
    _gameEventStreamSubscription = gameEventStream.listen((event) {
      if (event is CompoundFoundGameEvent) {
        _playCompoundFound();
      } else if (event is CompoundInvalidGameEvent) {
        _playCompoundIncorrect();
      } else if (event is LevelCompletedGameEvent) {
        _playLevelComplete();
      } else if (event is HintBoughtGameEvent) {
        _playHint();
      } else if (event is EasterEggGameEvent) {
        _playEasterEgg(event.easterEgg);
      }
    });
  }

  void setMute(bool mute) {
    _isMuted = mute;
    _keyValueStore?.storeBooleanSetting(BooleanSetting.dailyNotificationsEnabled, mute);
  }

  void toggleMute() {
    setMute(!_isMuted);
  }

  void playButtonClicked() {
    _playAsset("tap.wav", volume: 0.2);
  }

  void playStarCollected() {
    _playAsset("score.wav", volume: 0.4);
  }

  void _playLevelComplete() {
    _playAsset("success_02.wav");
  }

  void _playHint() {
    _playAsset("hint.wav");
  }

  void _playCompoundFound() {
    _playAsset("correct.wav", volume: 0.2);
  }

  void _playCompoundIncorrect() {
    _playAsset("incorrect.wav");
  }

  void playDailyGoalCompleted() {
    _playAsset("win_02.wav", volume: 0.2);
  }

  void _playAsset(String asset, {double volume = 0.3}) async {
    if (_isMuted) return;

    if (_playersByAsset.containsKey(asset) && _playersByAsset[asset] != null) {
      await _playersByAsset[asset]!.stop();
    } else {
      final player = AudioPlayer();
      player.setPlayerMode(PlayerMode.lowLatency);
      await player.setSource(AssetSource("sounds/$asset"));
      await player.setVolume(volume);
      await player.setReleaseMode(ReleaseMode.stop);
      _playersByAsset[asset] = player;
    }

    assert(_playersByAsset[asset] != null, "Player for asset $asset is null");
    await _playersByAsset[asset]!.resume();
  }

  void _playEasterEgg(EasterEgg easterEgg) {
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
              AudioManager.instance._playCompoundFound();
            },
            child: Text("Compound found"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance._playCompoundIncorrect();
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
              AudioManager.instance._playLevelComplete();
            },
            child: Text("Level complete"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance._playHint();
            },
            child: Text("Hint"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance.playDailyGoalCompleted();
            },
            child: Text("Daily goal completed"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance._playEasterEgg(EasterEgg.Orangensaft);
            },
            child: Text("Orangensaft"),
          ),
          ElevatedButton(
            onPressed: () {
              AudioManager.instance._playEasterEgg(EasterEgg.Apfelsaft);
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
                Icon(AudioManager.instance._isMuted ? Icons.volume_off : Icons.volume_up),
              ],
            ),
          ),
        ],
      )));
}