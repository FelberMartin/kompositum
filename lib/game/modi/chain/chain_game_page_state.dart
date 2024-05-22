import 'package:flutter/material.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/modi/chain/chain_game_level.dart';
import 'package:kompositum/game/modi/chain/chain_level_setup_provider.dart';
import 'package:kompositum/game/modi/chain/generator/chain_generator.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:kompositum/game/modi/classic/main_classic_game_page_state.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/screens/game_page.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:kompositum/widgets/play/dialogs/level_completed_dialog.dart';

class ChainGamePageState extends GamePageState {
  ChainGamePageState({
    required super.levelSetupProvider,
    required super.levelContentGenerator,
    required super.keyValueStore,
    required super.swappableDetector,
    required super.tutorialManager,
    required this.date,
  });

  factory ChainGamePageState.fromLocator(DateTime date) {
    return ChainGamePageState(
      levelSetupProvider: ChainLevelSetupProvider(),
      levelContentGenerator: locator<ChainGenerator>(),
      keyValueStore: locator<KeyValueStore>(),
      swappableDetector: locator<SwappableDetector>(),
      tutorialManager: locator<TutorialManager>(),
      date: date,
    );
  }

  final DateTime date;

  @override
  Future<GameLevel> generateGameLevel(LevelSetup levelSetup) async {
    final levelContent = await levelContentGenerator.generateFromLevelSetup(levelSetup);
    gameLevel = ChainGameLevel(
      levelContent as ComponentChain,
      maxShownComponentCount: levelSetup.difficulty.maxShownComponentCount,
    );
    toggleSelection((gameLevel as ChainGameLevel).currentModifier.id);
    return gameLevel;
  }

  @override
  void startGame() async {
    updateGameToLevel(date, isLevelAdvance: false);
  }

  @override
  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance) async {
    // Do nothing
  }

  @override
  void onGameLevelUpdate() {
    // Do nothing
  }

  @override
  String getLevelTitle() {
    return "Verstecktes Level";
  }

  @override
  LevelCompletedDialogType getLevelCompletedDialogType() {
    return LevelCompletedDialogType.daily;
  }

  @override
  void onLevelCompletedDialogClosed(LevelCompletedDialogResultType resultType) {
    // TODO: new dialog for secret level
    if (resultType == LevelCompletedDialogResultType.daily_backToOverview) {
      Navigator.pop(context);
      return;
    } else if (resultType == LevelCompletedDialogResultType.daily_continueWithClassic) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GamePage(state: MainClassicGamePageState.fromLocator())),
      );
      return;
    }
  }
}