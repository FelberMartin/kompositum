import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kompositum/screens/game_page.dart';

class GamePageDailyState extends GamePageState {
  GamePageDailyState({
    required super.levelProvider,
    required super.poolGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required this.date,
  });

  final DateTime date;

  @override
  void startGame() {
    updateGameToLevel(date, isLevelAdvance: false);
  }

  @override
  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance) async {
    poolGenerator.setBlockedCompounds([]);
  }

  @override
  String getLevelTitle() {
    var dateText = DateFormat("dd. MMM", "de").format(date);
    return dateText.substring(0, dateText.length - 1);
  }

  @override
  void onLevelCompletion() {
    keyValueStore.getDailiesCompleted().then((value) {
      value.add(date);
      keyValueStore.storeDailiesCompleted(value);
    });
    Navigator.pop(context);
  }
}
