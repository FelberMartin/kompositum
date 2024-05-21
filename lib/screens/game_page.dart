import 'dart:async';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/config/my_icons.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/chain/chain_game_level.dart';
import 'package:kompositum/game/chain/chain_generator.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
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
import '../game/level_provider.dart';
import '../game/pool_game_level.dart';
import '../util/ads/ad_manager.dart';
import '../widgets/common/my_icon_button.dart';
import '../widgets/play/bottom_content.dart';
import '../widgets/play/combination_area.dart';
import '../widgets/play/dialogs/level_completed_dialog.dart';
import '../widgets/play/dialogs/no_attempts_left_dialog.dart';
import '../widgets/play/dialogs/report_dialog.dart';
import '../widgets/play/top_row.dart';


enum GameMode {
  Pool, Chain
}

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
    required this.levelProvider,
    required this.poolGenerator,
    required this.keyValueStore,
    required this.swappableDetector,
    required this.tutorialManager,
    this.gameMode = GameMode.Pool
  });

  final LevelProvider levelProvider;
  final CompoundPoolGenerator poolGenerator;
  final KeyValueStore keyValueStore;
  final SwappableDetector swappableDetector;
  final TutorialManager tutorialManager;
  final GameMode gameMode;
  late AdManager adManager = locator<AdManager>();
  late DailyGoalSetManager dailyGoalSetManager = locator<DailyGoalSetManager>();

  late PoolGameLevel poolGameLevel;

  LevelSetup? levelSetup;
  int starCount = 0;
  bool isLoading = true;

  Map<SelectionType, int> selectionTypeToComponentId = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  /// Dummy values to set the selected components to after a compound was found
  /// where the components should be shown in the UI but are already removed from the pool.
  UniqueComponent? dummyModifier, dummyHead;

  UniqueComponent? get selectedModifier {
    if (poolGameLevel is ChainGameLevel) {
      return dummyModifier ?? (poolGameLevel as ChainGameLevel).currentModifier;
    }
    final selectedId = selectionTypeToComponentId[SelectionType.modifier];
    final selectedComponent = poolGameLevel.shownComponents.firstWhereOrNull((element) => element.id == selectedId);
    return selectedComponent ?? dummyModifier;
  }

  UniqueComponent? get selectedHead =>
      poolGameLevel.shownComponents.firstWhereOrNull((element) =>
          element.id == selectionTypeToComponentId[SelectionType.head]) ?? dummyHead;

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
    levelSetup = levelProvider.generateLevelSetup(levelIdentifier);
    setState(() {});

    if (gameMode == GameMode.Pool) {
      final compounds = await poolGenerator.generateFromLevelSetup(levelSetup!);
      final swappables = await swappableDetector.getSwappables(compounds);
      print("Finished new pool for new level");
      poolGameLevel = PoolGameLevel(
        compounds,
        maxShownComponentCount: levelSetup!.maxShownComponentCount,
        displayedDifficulty: levelSetup!.displayedDifficulty,
        swappableCompounds: swappables,
      );
    } else if (gameMode == GameMode.Chain) {
      final generator = ChainGenerator(locator<DatabaseInterface>());
      final compoundChain = await generator.generate(compoundCount: 10, frequencyClass: CompactFrequencyClass.medium);
      print("Finished new pool for new level");
      print(compoundChain.toString());
      poolGameLevel = ChainGameLevel(
        compoundChain,
        maxShownComponentCount: levelSetup!.maxShownComponentCount,
        displayedDifficulty: levelSetup!.displayedDifficulty,
        swappableCompounds: [],   // TODO: swappables for chain mode
      );
      toggleSelection((poolGameLevel as ChainGameLevel).currentModifier.id);
    } else {
      throw Exception("Unknown game mode");
    }

    _emitGameEvent(NewLevelStartGameEvent(levelSetup!, poolGameLevel));
    onPoolGameLevelUpdate();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance);

  /// Abstract method to override in subclasses. Called whenever
  /// the poolGameLevel is updated.
  void onPoolGameLevelUpdate();

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
    selectionTypeToComponentId[selectionType] = -1;
    if (shouldSetState) {
      setState(() {});
    }
  }

  void toggleSelection(int componentId) {
    final isComponentVisible = poolGameLevel.shownComponents.any((element) => element.id == componentId);
    if (!isComponentVisible) {
      return;
    }
    final selectionType = getSelectionTypeForComponentId(componentId);
    if (selectionType != null) {
      selectionTypeToComponentId[selectionType] = -1;
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

    final compound = poolGameLevel.checkForCompound(
        selectedModifier!.text, selectedHead!.text);

    // Invalid compound
    if (compound == null) {
      if (poolGameLevel.attemptsWatcher.allAttemptsUsed()) {
        showNoAttemptsLeftDialog();
      }
      _emitGameEvent(CompoundInvalidGameEvent(poolGameLevel));
    } else {    // Valid compound
      poolGameLevel.removeCompoundFromShown(compound, selectedModifier!,
          selectedHead!);
      _compoundFound(compound);
      setState(() {});
      if (poolGameLevel.isLevelFinished()) {
        levelCompleted();
      }
    }
    onPoolGameLevelUpdate();
  }

  void _compoundFound(Compound compound) {
    _increaseStarCount(Rewards.starsCompoundCompleted);
    _emitGameEvent(CompoundFoundGameEvent(compound));
    resetToNoSelection();
    if (poolGameLevel is ChainGameLevel) {
      toggleSelection((poolGameLevel as ChainGameLevel).currentModifier.id);
    }
    onPoolGameLevelUpdate();
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
    _emitGameEvent(LevelCompletedGameEvent(levelSetup!, poolGameLevel));
    showLevelCompletedDialog();
  }

  @override
  void dispose() {
    tutorialManager.deregisterGameEventStream();
    super.dispose();
  }

  List<ComponentInfo> getComponentInfos() {
    return poolGameLevel.shownComponents.map((component) {
      final selectionType = getSelectionTypeForComponentId(component.id);
      final hint = poolGameLevel.hints
          .firstWhereOrNull((hint) => hint.hintedComponent == component);
      return ComponentInfo(component, selectionType, hint);
    }).toList();
  }

  ComponentInfo? getSelectedModifierInfo() {
    if (selectedModifier == null) {
      return null;
    }
    final hint = poolGameLevel.hints
        .firstWhereOrNull((hint) => hint.hintedComponent == selectedModifier);
    return ComponentInfo(selectedModifier!, SelectionType.modifier, hint);
  }

  ComponentInfo? getSelectedHeadInfo() {
    if (selectedHead == null) {
      return null;
    }
    final hint = poolGameLevel.hints
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
        isHintAvailable: poolGameLevel.canRequestHint(starCount),
        hintCost: poolGameLevel.getHintCost(),
      ),
    );
  }

  void onNoAttemptsLeftDialogClose(NoAttemptsLeftDialogAction action) {
    Navigator.pop(context);
    resetToNoSelection();

    switch (action) {
      case NoAttemptsLeftDialogAction.hint:
        buyHint();
        poolGameLevel.attemptsWatcher.resetLocalAttempts();
        onPoolGameLevelUpdate();
        break;
      case NoAttemptsLeftDialogAction.restart:
        adManager.showAd(context).then((_) {
          poolGameLevel.attemptsWatcher.resetAllAttempts();
          restartLevel();
        });
        break;
    }
  }

  void buyHint() {
    if (!poolGameLevel.canRequestHint(starCount)) {
      return;
    }
    final cost = poolGameLevel.getHintCost();
    final hint = poolGameLevel.requestHint(starCount)!;
    resetToNoSelection();
    if (hint.type == HintComponentType.modifier) {
      selectionTypeToComponentId[SelectionType.modifier] = hint.hintedComponent.id;
    }

    _emitGameEvent(HintBoughtGameEvent(hint));
    _decreaseStarCount(cost);
    onPoolGameLevelUpdate();
    poolGameLevel.attemptsWatcher.resetLocalAttempts();
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
        difficulty: poolGameLevel.displayedDifficulty,
        failedAttempts: poolGameLevel.attemptsWatcher.overAllAttemptsFailed,
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
    final compound = poolGameLevel.getCompoundIfExisting(
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
                  displayedDifficulty: levelSetup!.displayedDifficulty,
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
                          maxAttempts: poolGameLevel.attemptsWatcher.maxAttempts,
                          attemptsLeft: poolGameLevel.attemptsWatcher.attemptsLeft,
                          gameEventStream: GameEventStream.instance.stream,
                          isReportVisible: shouldShowReportButton(),
                          onReportPressed: showReportDialog,
                          progress: poolGameLevel.getLevelProgress(),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child:
                          isLoading ? BottomContent.loading() : BottomContent(
                            onToggleSelection: toggleSelection,
                            componentInfos: getComponentInfos(),
                            hiddenComponentsCount:
                                poolGameLevel.hiddenComponents.length,
                            hintCost: poolGameLevel.getHintCost(),
                            hintButtonInfo: MyIconButtonInfo(
                              icon: MyIcons.hint,
                              onPressed: () {
                                buyHint();
                              },
                              enabled: poolGameLevel.canRequestHint(starCount),
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
