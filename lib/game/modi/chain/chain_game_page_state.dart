import 'package:flutter/material.dart';
import 'package:kompositum/config/locator.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_setup.dart';
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
  static const int fixedModifierId = -100;

  void _setFixedModifier() {
    selectionTypeToComponentId[SelectionType.modifier] = fixedModifierId;
  }

  @override
  UniqueComponent? get selectedModifier {
    return dummyModifier ?? (gameLevel as ChainGameLevel).currentModifier;
  }

    @override
  void startGame() async {
    _setFixedModifier();
    keepModifierFixed = true;
    updateGameToLevel(date, isLevelAdvance: false);
  }

  @override
  Future<GameLevel> generateGameLevel(LevelSetup levelSetup) async {
    final levelContent = await levelContentGenerator.generateFromLevelSetup(levelSetup);
    print("LevelContent: $levelContent");
    gameLevel = ChainGameLevel(
      levelContent as ComponentChain,
      maxShownComponentCount: levelSetup.difficulty.maxShownComponentCount,
    );
    return gameLevel;
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
    return LevelCompletedDialogType.secretLevel;
  }

  @override
  void onLevelCompletedDialogClosed(LevelCompletedDialogResultType resultType) {
    if (resultType == LevelCompletedDialogResultType.secretLevel_continue) {
      Navigator.pop(context);
      return;
    }
  }
}