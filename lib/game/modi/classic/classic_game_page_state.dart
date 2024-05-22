import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/modi/classic/classic_game_level.dart';
import 'package:kompositum/game/modi/classic/generator/classic_level_content.dart';
import 'package:kompositum/screens/game_page.dart';

abstract class ClassicGamePageState extends GamePageState {
  ClassicGamePageState({
    required super.levelSetupProvider,
    required super.levelContentGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager
  });

  @override
  Future<GameLevel> generateGameLevel(LevelSetup levelSetup) async {
    final levelContent = await levelContentGenerator.generateFromLevelSetup(levelSetup);
    final swappables = await swappableDetector.getSwappables(levelContent.getCompounds());
    return ClassicGameLevel(
      levelContent as ClassicLevelContent,
      maxShownComponentCount: levelSetup.difficulty.maxShownComponentCount,
      swappableCompounds: swappables,
    );
  }
}
