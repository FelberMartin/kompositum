import 'dart:async';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/widgets/common/my_background.dart';
import 'package:kompositum/widgets/common/my_dialog.dart';
import 'package:kompositum/widgets/play/star_fly_animation.dart';

import '../data/models/compound.dart';
import '../game/attempts_watcher.dart';
import '../game/hints/hint.dart';
import '../game/level_provider.dart';
import '../game/pool_game_level.dart';
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
    required this.levelProvider,
    required this.poolGenerator,
    required this.keyValueStore,
    required this.swappableDetector
  });

  final LevelProvider levelProvider;
  final CompoundPoolGenerator poolGenerator;
  final KeyValueStore keyValueStore;
  final SwappableDetector swappableDetector;
  late PoolGameLevel poolGameLevel;
  late AttemptsWatcher attemptsWatcher;

  LevelSetup? levelSetup;
  int starCount = 0;
  bool isLoading = true;

  final StreamController<String> wordCompletionEventStream =
      StreamController<String>.broadcast();
  var starCountIncreaseStream =
      StreamController<StarIncreaseRequest>.broadcast();


  Map<SelectionType, int> selectionTypeToComponentId = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  /// Dummy values to set the selected components to after a compound was found
  /// where the components should be shown in the UI but are already removed from the pool.
  UniqueComponent? dummyModifier, dummyHead;

  UniqueComponent? get selectedModifier =>
      poolGameLevel.shownComponents.firstWhereOrNull((element) =>
          element.id == selectionTypeToComponentId[SelectionType.modifier]) ?? dummyModifier;

  UniqueComponent? get selectedHead =>
      poolGameLevel.shownComponents.firstWhereOrNull((element) =>
          element.id == selectionTypeToComponentId[SelectionType.head]) ?? dummyHead;

  @override
  void initState() {
    super.initState();
    keyValueStore.getStarCount().then((value) {
      starCount = value;
    });
    keyValueStore.getBlockedCompoundNames().then((value) {
      poolGenerator.setBlockedCompounds(value);
    });
    attemptsWatcher = AttemptsWatcher(maxAttempts: 5);

    startGame();
  }

  void startGame();

  void updateGameToLevel(Object levelIdentifier, {bool isLevelAdvance = true}) async {
    preLevelUpdate(levelIdentifier, isLevelAdvance);
    setState(() {
      isLoading = true;
    });

    print("Generating new pool for new level");
    levelSetup = levelProvider.generateLevelSetup(levelIdentifier);
    setState(() {});

    final compounds = await poolGenerator.generateFromLevelSetup(levelSetup!);
    final swappables = await swappableDetector.getSwappables(compounds);
    print("Finished new pool for new level");
    poolGameLevel = PoolGameLevel(
      compounds,
      maxShownComponentCount: levelSetup!.maxShownComponentCount,
      displayedDifficulty: levelSetup!.displayedDifficulty,
      swappableCompounds: swappables,
    );

    setState(() {
      isLoading = false;
    });
  }

  Future<void> preLevelUpdate(Object levelIdentifier, isLevelAdvance);

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
    resetSelection(SelectionType.modifier);
    resetSelection(SelectionType.head);
  }

  void resetSelection(SelectionType selectionType) {
    selectionTypeToComponentId[selectionType] = -1;
    setState(() {});
  }

  void toggleSelection(int componentId) async {
    final selectionType = getSelectionTypeForComponentId(componentId);
    if (selectionType != null) {
      selectionTypeToComponentId[selectionType] = -1;
    } else if (selectionTypeToComponentId[SelectionType.modifier] == -1) {
      selectionTypeToComponentId[SelectionType.modifier] = componentId;
    } else {
      selectionTypeToComponentId[SelectionType.head] = componentId;
    }
    _checkCompoundCompletion();
    setState(() {});
  }

  void _checkCompoundCompletion() async {
    if (selectedModifier == null || selectedHead == null) {
      return;
    }

    final compound = poolGameLevel.getCompoundIfExisting(
        selectedModifier!.text, selectedHead!.text);
    if (compound == null) {
      attemptsWatcher.attemptUsed();
      if (!attemptsWatcher.anyAttemptsLeft()) {
        showNoAttemptsLeftDialog();
      }
    } else {
      poolGameLevel.removeCompoundFromShown(compound, selectedModifier!,
          selectedHead!);
      _compoundFound(compound);
      attemptsWatcher.resetAttempts();
      setState(() {});
      if (poolGameLevel.isLevelFinished()) {
        _levelFinished();
      }
    }
  }

  void _compoundFound(Compound compound) {
    _increaseStarCount(Rewards.starsCompoundCompleted);
    emitWordCompletionEvent(compound.name);
    resetToNoSelection();
    setState(() {
      dummyModifier = UniqueComponent(compound.modifier, 0);
      dummyHead = UniqueComponent(compound.head, 0);
    });
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        dummyModifier = null;
        dummyHead = null;
      });
    });
  }

  void _increaseStarCount(int amount, {Origin origin = Origin.compoundCompletion}) {
    assert(amount >= 0);
    starCountIncreaseStream.sink.add(StarIncreaseRequest(amount, origin));
    keyValueStore.storeStarCount(starCount);
    setState(() {});
  }

  void _decreaseStarCount(int amount) {
    assert(amount >= 0);
    starCount -= amount;
    keyValueStore.storeStarCount(starCount);
    setState(() {});
  }

  void emitWordCompletionEvent(String word) {
    wordCompletionEventStream.sink.add(word);
  }

  void _levelFinished() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    showLevelCompletedDialog();
  }

  @override
  void dispose() {
    wordCompletionEventStream.close();
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
      dialog: NoAttemptsLeftDialog(
        onActionPressed: onNoAttemptsLeftDialogClose,
        isHintAvailable: poolGameLevel.canRequestHint() && starCount >= getHintCost(),
        hintCost: getHintCost(),
      ),
    );
  }

  void onNoAttemptsLeftDialogClose(NoAttemptsLeftDialogAction action) {
    Navigator.pop(context);
    resetToNoSelection();

    switch (action) {
      case NoAttemptsLeftDialogAction.hint:
        buyHint();
        break;
      case NoAttemptsLeftDialogAction.restart:
      // TODO: show advertisement
        restartLevel();
        break;
    }

    attemptsWatcher.resetAttempts();
  }

  void buyHint() {
    if (!poolGameLevel.canRequestHint()) {
      return;
    }
    final cost = getHintCost();
    if (starCount < cost) {
      return;
    }

    final hint = poolGameLevel.requestHint()!;
    resetToNoSelection();
    if (hint.type == HintComponentType.modifier) {
      selectionTypeToComponentId[SelectionType.modifier] = hint.hintedComponent.id;
    }

    _decreaseStarCount(cost);
    setState(() {});
  }

  int getHintCost() {
    return Costs.hintCost(failedAttempts: attemptsWatcher.attemptsUsed);
  }

  void showReportDialog() {
    animateDialog(
      context: context,
      dialog: ReportDialog(
        modifier: selectedModifier!.text,
        head: selectedHead!.text,
        onClose: () {
          Navigator.pop(context);
          resetToNoSelection();
        },
      ),
    );
  }

  void showLevelCompletedDialog() {
    animateDialog(
      context: context,
      barrierDismissible: false,
      dialog: LevelCompletedDialog(
        difficulty: poolGameLevel.displayedDifficulty,
        onContinuePressed: () {
          Navigator.pop(context);
          var reward = Rewards.byDifficulty(poolGameLevel.displayedDifficulty);
          _increaseStarCount(reward, origin: Origin.levelCompletion);
          resetToNoSelection();
          onLevelCompletion();
        },
      ),
    );
  }

  void onLevelCompletion();

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
                  levelProgress: true ? 0 : poolGameLevel.getLevelProgress(), // The progress is currently not shown
                  starCount: starCount,
                ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: isLoading ? CombinationArea.loading(wordCompletionEventStream.stream) : CombinationArea(
                          selectedModifier: getSelectedModifierInfo(),
                          selectedHead: getSelectedHeadInfo(),
                          onResetSelection: resetSelection,
                          maxAttempts: attemptsWatcher.maxAttempts,
                          attemptsLeft: attemptsWatcher.attemptsLeft,
                          wordCompletionEventStream:
                              wordCompletionEventStream.stream,
                          isReportVisible: shouldShowReportButton(),
                          onReportPressed: showReportDialog,
                        ),
                      ),
                      isLoading ? BottomContent.loading() : BottomContent(
                        onToggleSelection: toggleSelection,
                        componentInfos: getComponentInfos(),
                        hiddenComponentsCount:
                            poolGameLevel.hiddenComponents.length,
                        hintCost: getHintCost(),
                        hintButtonInfo: MyIconButtonInfo(
                          icon: FontAwesomeIcons.lightbulb,
                          onPressed: () {
                            buyHint();
                          },
                          enabled: poolGameLevel.canRequestHint() && starCount >= getHintCost(),
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
          starIncreaseRequestStream: starCountIncreaseStream.stream,
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
