import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/modi/classic/classic_game_level.dart';
import 'package:kompositum/screens/game_page.dart';

abstract class ClassicGamePageState extends GamePageState {
  ClassicGamePageState({
    required super.levelProvider,
    required super.poolGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager
  });

  @override
  Future<GameLevel> generateGameLevel(LevelSetup levelSetup) async {
    final compounds = await poolGenerator.generateFromLevelSetup(levelSetup!);
    final swappables = await swappableDetector.getSwappables(compounds);
    return ClassicGameLevel(
      compounds,
      maxShownComponentCount: levelSetup.difficulty.maxShownComponentCount,
      swappableCompounds: swappables,
    );
  }
}
