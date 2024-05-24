import 'dart:async';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:flutter/material.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/modi/chain/chain_game_level.dart';
import 'package:kompositum/game/modi/chain/generator/chain_generator.dart';
import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/util/audio_manager.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:kompositum/widgets/common/my_background.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';
import 'package:kompositum/widgets/play/star_fly_animation.dart';

import '../config/locator.dart';
import '../data/database_interface.dart';
import '../data/models/compound.dart';
import '../game/game_event/game_event.dart';
import '../game/game_event/game_event_stream.dart';
import '../game/goals/daily_goal_set_manager.dart';
import '../game/hints/hint.dart';
import '../game/level_setup_provider.dart';
import '../util/ads/ad_manager.dart';
import '../widgets/common/my_icon_button.dart';
import '../widgets/play/bottom_content.dart';
import '../widgets/play/combination_area.dart';
import '../widgets/play/dialogs/level_completed_dialog.dart';
import '../widgets/play/dialogs/no_attempts_left_dialog.dart';
import '../widgets/play/dialogs/report_dialog.dart';
import '../widgets/play/top_row.dart';


class GamePage extends StatefulWidget {
  const GamePage(
      {super.key,
      required this.state});

  final GamePageState state;

  @override
  State<GamePage> createState() => state;
}

abstract class GamePageState extends State<GamePage> {
  GamePageState({
    required this.levelSetupProvider,
    required this.levelContentGenerator,
    required this.keyValueStore,
    required this.swappableDetector,
    required this.tutorialManager,
  });

  final LevelSetupProvider levelSetupProvider;
  final LevelContentGenerator levelContentGenerator;
  final KeyValueStore keyValueStore;
  final SwappableDetector swappableDetector;
  final TutorialManager tutorialManager;
  late AdManager adManager = locator<AdManager>();
  late DailyGoalSetManager dailyGoalSetManager = locator<DailyGoalSetManager>();

  late GameLevel gameLevel;

  LevelSetup? levelSetup;
  int starCount = 0;
  bool isLoading = true;

  bool keepModifierFixed = false;

  Map<SelectionType, int> selectionTypeToComponentId = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  /// Dummy values to set the selected components to after a compound was found
  /// where the components should be shown in the UI but are already removed from the pool.
  UniqueComponent? dummyModifier, dummyHead;

  UniqueComponent? get selectedModifier {
    final selectedId = selectionTypeToComponentId[SelectionType.modifier];
    final selectedComponent = gameLevel.shownComponents.firstWhereOrNull((element) => element.id == selectedId);
    return selectedComponent ?? dummyModifier;
  }

  UniqueComponent? get selectedHead {
    final selectedId = selectionTypeToComponentId[SelectionType.head];
    final selectedComponent = gameLevel.shownComponents.firstWhereOrNull((element) => element.id == selectedId);
    return selectedComponent ?? dummyHead;
  }

  @override
  void initState() {
    super.initState();
    keyValueStore.getStarCount().then((value) {
      starCount = value;
    });

    tutorialManager.animateDialog = _launchTutorialDialog;
    tutorialManager.registerGameEventStream(GameEventStream.instance.stream);

    startGame();
  }

  void _launchTutorialDialog(Widget dialog) {
    Future.delayed(const Duration(milliseconds: 500)).then((value) => animateDialog(
      context: context,
      dialog: dialog,
      barrierDismissible: false,
    ));
  }

  void startGame();

  void updateGameToLevel(Object levelIdentifier, {bool isLevelAdvance = true}) async {
    await preLevelUpdate(levelIdentifier, isLevelAdvance);
    setState(() {
      isLoading = true;
    });

    print("Generating new pool for new level");
    levelSetup = levelSetupProvider.generateLevelSetup(levelIdentifier);
    setState(() {});

    gameLevel = await generateGameLevel(levelSetup!);
    print("Finished new pool for new level");

    _emitGameEvent(NewLevelStartGameEvent(levelSetup!, gameLevel));
    onGameLevelUpdate();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance);

  Future<GameLevel> generateGameLevel(LevelSetup levelSetup);

  /// Abstract method to override in subclasses. Called whenever
  /// the poolGameLevel is updated.
  void onGameLevelUpdate();

  void restartLevel() {
    updateGameToLevel(levelSetup!.levelIdentifier, isLevelAdvance: false);
  }

  SelectionType? getSelectionTypeForComponentId(int componentId) {
    for (MapEntry<SelectionType, int> entry in selectionTypeToComponentId.entries) {
      final selectionType = entry.key;
      final selectedId = entry.value;
      if (selectedId == componentId) {
        return selectionType;
      }
    }
    return null;
  }

  void resetToNoSelection() {
    resetSelection(SelectionType.modifier, shouldSetState: false);
    resetSelection(SelectionType.head);
  }

  void resetSelection(SelectionType selectionType, {bool shouldSetState = true}) {
    if (keepModifierFixed && selectionType == SelectionType.modifier) {
      return;
    }
    selectionTypeToComponentId[selectionType] = -1;
    if (shouldSetState) {
      setState(() {});
    }
  }

  void toggleSelection(int componentId) {
    final isComponentVisible = gameLevel.shownComponents.any((element) => element.id == componentId);
    if (!isComponentVisible) {
      return;
    }
    final selectionType = getSelectionTypeForComponentId(componentId);
    if (selectionType != null) {
      resetSelection(selectionType, shouldSetState: false);
    } else if (selectionTypeToComponentId[SelectionType.modifier] == -1) {
      selectionTypeToComponentId[SelectionType.modifier] = componentId;
    } else {
      selectionTypeToComponentId[SelectionType.head] = componentId;
    }
    _checkCompoundCompletion();
    _emitGameEvent(const ComponentClickedGameEvent());
    setState(() {});
  }

  void _checkCompoundCompletion() {
    if (dummyModifier != null && dummyHead != null) {
      // Reset dummy values, as they are only used for the animation, and not
      // relevant for the actual game state.
      dummyModifier = null;
      dummyHead = null;
    }
    if (selectedModifier == null || selectedHead == null) {
      return;
    }

    final compound = gameLevel.checkForCompound(
        selectedModifier!.text, selectedHead!.text);

    // Invalid compound
    if (compound == null) {
      if (gameLevel.attemptsWatcher.allAttemptsUsed()) {
        showNoAttemptsLeftDialog();
      }
      _emitGameEvent(CompoundInvalidGameEvent(gameLevel));
    } else {    // Valid compound
      gameLevel.removeCompoundFromShown(compound, selectedModifier!,
          selectedHead!);
      _compoundFound(compound);
      setState(() {});
      if (gameLevel.isLevelFinished()) {
        levelCompleted();
      }
    }
    onGameLevelUpdate();
  }

  void _compoundFound(Compound compound) {
    _increaseStarCount(Rewards.starsCompoundCompleted);
    _emitGameEvent(CompoundFoundGameEvent(compound));
    resetToNoSelection();
    if (gameLevel is ChainGameLevel) {
      toggleSelection((gameLevel as ChainGameLevel).currentModifier.id);
    }
    onGameLevelUpdate();
    _checkForEasterEgg(compound);

    setState(() {
      dummyModifier = UniqueComponent(compound.modifier);
      dummyHead = UniqueComponent(compound.head);
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        dummyModifier = null;
        dummyHead = null;
      });
    });
  }

  void _checkForEasterEgg(Compound compound) {
    EasterEgg.values.forEach((easterEgg) {
      if (compound.name.toLowerCase() == easterEgg.compound.toLowerCase()) {
        AudioManager.instance.playEasterEgg(easterEgg);
      }
    });
  }

  void _increaseStarCount(int amount,
      {StarIncreaseRequestOrigin origin = StarIncreaseRequestOrigin.compoundCompletion}
  ) {
    assert(amount >= 0);
    _emitGameEvent(StarIncreaseRequestGameEvent(amount, origin));
    keyValueStore.increaseStarCount(amount);
    setState(() {});
  }

  void _decreaseStarCount(int amount) {
    assert(amount >= 0);
    starCount -= amount;
    keyValueStore.storeStarCount(starCount);
    setState(() {});
  }

  void _emitGameEvent(GameEvent event) {
    GameEventStream.instance.addEvent(event);
  }

  void levelCompleted() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    _emitGameEvent(LevelCompletedGameEvent(levelSetup!, gameLevel));
    showLevelCompletedDialog();
  }

  @override
  void dispose() {
    tutorialManager.deregisterGameEventStream();
    super.dispose();
  }

  List<ComponentInfo> getComponentInfos() {
    return gameLevel.shownComponents.map((component) {
      final selectionType = getSelectionTypeForComponentId(component.id);
      final hint = gameLevel.hints
          .firstWhereOrNull((hint) => hint.hintedComponent == component);
      return ComponentInfo(component, selectionType, hint);
    }).toList();
  }

  ComponentInfo? getSelectedModifierInfo() {
    if (selectedModifier == null) {
      return null;
    }
    final hint = gameLevel.hints
        .firstWhereOrNull((hint) => hint.hintedComponent == selectedModifier);
    return ComponentInfo(selectedModifier!, SelectionType.modifier, hint);
  }

  ComponentInfo? getSelectedHeadInfo() {
    if (selectedHead == null) {
      return null;
    }
    final hint = gameLevel.hints
        .firstWhereOrNull((hint) => hint.hintedComponent == selectedHead);
    return ComponentInfo(selectedHead!, SelectionType.head, hint);
  }

  void showNoAttemptsLeftDialog() {
    animateDialog(
      context: context,
      barrierDismissible: false,
      canPop: false,
      dialog: NoAttemptsLeftDialog(
        onActionPressed: onNoAttemptsLeftDialogClose,
        isHintAvailable: gameLevel.canRequestHint(starCount),
        hintCost: gameLevel.getHintCost(),
      ),
    );
  }

  void onNoAttemptsLeftDialogClose(NoAttemptsLeftDialogAction action) {
    Navigator.pop(context);
    resetToNoSelection();

    switch (action) {
      case NoAttemptsLeftDialogAction.hint:
        buyHint();
        gameLevel.attemptsWatcher.resetLocalAttempts();
        onGameLevelUpdate();
        break;
      case NoAttemptsLeftDialogAction.restart:
        adManager.showAd(context).then((_) {
          gameLevel.attemptsWatcher.resetOverallAttempts();
          restartLevel();
        });
        break;
    }
  }

  void buyHint() {
    if (!gameLevel.canRequestHint(starCount)) {
      return;
    }
    final cost = gameLevel.getHintCost();
    final hint = gameLevel.requestHint(starCount)!;
    resetToNoSelection();
    if (hint.type == HintComponentType.modifier) {
      selectionTypeToComponentId[SelectionType.modifier] = hint.hintedComponent.id;
    }

    _emitGameEvent(HintBoughtGameEvent(hint));
    _decreaseStarCount(cost);
    onGameLevelUpdate();
    gameLevel.attemptsWatcher.resetLocalAttempts();
    setState(() {});
  }

  void showReportDialog() {
    animateDialog(
      context: context,
      dialog: ReportDialog(
        modifier: selectedModifier!.text,
        head: selectedHead!.text,
        levelIdentifier: levelSetup!.levelIdentifier,
        onClose: () {
          Navigator.pop(context);
          resetToNoSelection();
        },
      ),
    );
  }

  void showLevelCompletedDialog() async {
    final nextLevelNumber = await keyValueStore.getLevel();   // This is only used in the daily mode.
    final dailyGoalSetProgression = await dailyGoalSetManager.getProgression();
    dailyGoalSetManager.resetProgression();

    if (!context.mounted) {
      return;
    }
    animateDialog(
      context: context,
      barrierDismissible: false,
      canPop: false,
      dialog: LevelCompletedDialog(
        type: getLevelCompletedDialogType(),
        difficulty: levelSetup!.difficulty,
        failedAttempts: gameLevel.attemptsWatcher.overAllAttemptsFailed,
        nextLevelNumber: nextLevelNumber,
        dailyGoalSetProgression: dailyGoalSetProgression,
        onContinue: (result) {
          Navigator.pop(context);
          _increaseStarCount(result.starCountIncrease, origin: StarIncreaseRequestOrigin.levelCompletion);
          resetToNoSelection();
          onLevelCompletedDialogClosed(result.type);
        },
      ),
    );
  }

  LevelCompletedDialogType getLevelCompletedDialogType();

  void onLevelCompletedDialogClosed(LevelCompletedDialogResultType resultType);

  bool shouldShowReportButton() {
    if (selectedModifier == null || selectedHead == null) {
      return false;
    }
    final compound = gameLevel.getCompoundIfExisting(
        selectedModifier!.text, selectedHead!.text);
    return compound == null;
  }

  String getLevelTitle();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: MyBackground(),
        ),
        Scaffold(
          appBar: levelSetup == null
              ? null
              : TopRow(
                  onBackPressed: () {
                    Navigator.pop(context);
                  },
                  difficulty: levelSetup!.difficulty,
                  title: getLevelTitle(),
                  starCount: starCount,
                ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: isLoading ? CombinationArea.loading(GameEventStream.instance.stream) : CombinationArea(
                          selectedModifier: getSelectedModifierInfo(),
                          selectedHead: getSelectedHeadInfo(),
                          onResetSelection: resetSelection,
                          maxAttempts: gameLevel.attemptsWatcher.maxAttempts,
                          attemptsLeft: gameLevel.attemptsWatcher.attemptsLeft,
                          gameEventStream: GameEventStream.instance.stream,
                          isReportVisible: shouldShowReportButton(),
                          onReportPressed: showReportDialog,
                          progress: gameLevel.getLevelProgress(),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child:
                          isLoading ? BottomContent.loading() : BottomContent(
                            onToggleSelection: toggleSelection,
                            componentInfos: getComponentInfos(),
                            hiddenComponentsCount:
                                gameLevel.hiddenComponents.length,
                            hintCost: gameLevel.getHintCost(),
                            hintButtonInfo: MyIconButtonInfo(
                              icon: MyIcons.hint,
                              onPressed: () {
                                buyHint();
                              },
                              enabled: gameLevel.canRequestHint(starCount),
                            ),
                            showClickIndicatorIndex: tutorialManager.showClickIndicatorIndex,
                          ),
                      ),
                    ],
                  ),
          ),
        ),
        StarFlyAnimations(
          onIncreaseStarCount: (amount) {
            starCount += amount;
            setState(() {});
          },
          gameEventStream: GameEventStream.instance.stream,
        ),
      ],
    );
  }
}

class ComponentInfo {
  final UniqueComponent component;
  final SelectionType? selectionType;
  final Hint? hint;

  ComponentInfo(this.component, this.selectionType, this.hint);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentInfo &&
          runtimeType == other.runtimeType &&
          component == other.component;

  @override
  int get hashCode => component.hashCode;
}

// enum for SelectionType to be either modifier or head
enum SelectionType {
  modifier,
  head;
}
