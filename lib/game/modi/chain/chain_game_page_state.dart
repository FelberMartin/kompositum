import 'package:kompositum/config/locator.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/modi/chain/chain_game_level.dart';
import 'package:kompositum/game/modi/pool/classic_game_level.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/widgets/play/dialogs/level_completed_dialog.dart';

class ChainGamePageState extends GamePageState {
  ChainGamePageState({
    required super.levelProvider,
    required super.poolGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager
  });

  @override
  void startGame() async {
    updateGameToLevel(currentLevel, isLevelAdvance: false);
  }

  @override
  Future<GameLevel> generateGameLevel(LevelSetup levelSetup) async {
    final generator = ChainGenerator(locator<DatabaseInterface>());
      final compoundChain = await generator.generate(compoundCount: 10, frequencyClass: CompactFrequencyClass.medium);
      print("Finished new pool for new level");
      print(compoundChain.toString());
      gameLevel = ChainGameLevel(
        compoundChain,
        maxShownComponentCount: levelSetup.difficulty.maxShownComponentCount,
        swappableCompounds: [],   // TODO: swappables for chain mode
      );
      toggleSelection((gameLevel as ChainGameLevel).currentModifier.id);
      return gameLevel;
  }

  @override
  LevelCompletedDialogType getLevelCompletedDialogType() {
    // TODO: implement getLevelCompletedDialogType
    throw UnimplementedError();
  }

  @override
  String getLevelTitle() {
    // TODO: implement getLevelTitle
    throw UnimplementedError();
  }

  @override
  void onGameLevelUpdate() {
    // TODO: implement onGameLevelUpdate
  }

  @override
  void onLevelCompletedDialogClosed(LevelCompletedDialogResultType resultType) {
    // TODO: implement onLevelCompletedDialogClosed
  }

  @override
  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance) {
    // TODO: implement preLevelUpdate
    throw UnimplementedError();
  }
}