
import 'package:kompositum/game/difficulty.dart';

enum LevelType {
  /// Classic levels are in the "classic" modus and the main levels of the game.
  mainClassic,

  /// Daily levels are special levels that are only available for a day. They
  /// are also in the "classic" modus.
  dailyClassic,

  /// Chain levels are special levels that are only available for a day. They
  /// are in the "chain" modus.
  secretChain,
}

class LevelSetup {
  final Object levelIdentifier;
  final LevelType levelType;
  final int compoundCount;
  final int poolGenerationSeed;
  final Difficulty difficulty;
  final bool ignoreBlockedCompounds;

  LevelSetup({
    required this.levelIdentifier,
    required this.compoundCount,
    required this.poolGenerationSeed,
    this.levelType = LevelType.mainClassic,
    this.difficulty = Difficulty.easy,
    this.ignoreBlockedCompounds = false,
  });

  @override
  String toString() {
    return "LevelSetup("
        "levelIdentifier: $levelIdentifier, "
        "levelType: $levelType,"
        "compoundCount: $compoundCount, "
        "poolGenerationSeed: $poolGenerationSeed, "
        "displayedDifficulty: $difficulty)"
        "ignoreBlockedCompounds: $ignoreBlockedCompounds";
  }
}