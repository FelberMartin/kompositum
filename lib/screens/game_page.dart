import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:format/format.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/main.dart';
import 'package:kompositum/config/theme.dart';
import 'package:kompositum/widgets/common/util/clip_shadow_path.dart';
import 'package:kompositum/widgets/common/my_buttons.dart';
import 'package:kompositum/widgets/common/my_app_bar.dart';

import '../game/attempts_watcher.dart';
import '../game/hints/hint.dart';
import '../game/level_provider.dart';
import '../game/pool_game_level.dart';
import '../config/locator.dart';
import '../widgets/common/util/rounded_edge_clipper.dart';
import '../widgets/play/bottom_content.dart';
import '../widgets/play/combination_area.dart';
import '../widgets/play/dialogs/no_attempts_left_dialog.dart';
import '../widgets/common/my_icon_button.dart';
import '../widgets/play/top_row.dart';

class GamePage extends StatefulWidget {
  const GamePage(
      {super.key,
      required this.title,
      required this.levelProvider,
      required this.poolGenerator,
      required this.keyValueStore,
      required this.swappableDetector});

  final String title;
  final LevelProvider levelProvider;
  final CompoundPoolGenerator poolGenerator;
  final KeyValueStore keyValueStore;
  final SwappableDetector swappableDetector;

  @override
  State<GamePage> createState() => GamePageState(
    levelProvider: levelProvider,
    poolGenerator: poolGenerator,
    keyValueStore: keyValueStore,
    swappableDetector: swappableDetector
  );
}

class GamePageState extends State<GamePage> {
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

  late int levelNumber;
  bool isLoading = true;

  final StreamController<String> wordCompletionEventStream =
      StreamController<String>.broadcast();

  Map<SelectionType, int> selectionTypeToComponentId = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  UniqueComponent? get selectedModifier =>
      poolGameLevel.shownComponents.firstWhereOrNull((element) =>
          element.id == selectionTypeToComponentId[SelectionType.modifier]);

  UniqueComponent? get selectedHead =>
      poolGameLevel.shownComponents.firstWhereOrNull((element) =>
          element.id == selectionTypeToComponentId[SelectionType.head]);

  @override
  void initState() {
    super.initState();
    keyValueStore.getLevel().then((value) {
      levelNumber = value;
      updateGameToNewLevel(levelNumber);
    });
    keyValueStore.getBlockedCompoundNames().then((value) {
      poolGenerator.setBlockedCompounds(value);
    });
    attemptsWatcher = AttemptsWatcher(maxAttempts: 5);
  }

  void showNoAttemptsLeftDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return NoAttemptsLeftDialog();
      },
    );
  }

  void updateGameToNewLevel(int newLevelNumber) async {
    keyValueStore.storeLevel(newLevelNumber);
    // Save the blocked compounds BEFORE the generation of the new level,
    // so that when regenerating the same level later, the same compounds
    // are blocked.
    keyValueStore.storeBlockedCompounds(poolGenerator.getBlockedCompounds());
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      isLoading = true;
    });
    levelNumber = newLevelNumber;
    print("Generating new pool for new level");
    final levelSetup = levelProvider.generateLevelSetup(levelNumber);
    final compounds = await poolGenerator.generateFromLevelSetup(levelSetup);
    final swappables = await swappableDetector.getSwappables(compounds);
    print("Finished new pool for new level");
    poolGameLevel = PoolGameLevel(
      compounds,
      maxShownComponentCount: levelSetup.maxShownComponentCount,
      displayedDifficulty: levelSetup.displayedDifficulty,
      swappableCompounds: swappables,
    );
    setState(() {
      isLoading = false;
    });
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

  void resetSelection(SelectionType selectionType, {bool updateState = true}) {
    selectionTypeToComponentId[selectionType] = -1;
    if (updateState) {
      setState(() {});
    }
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
    checkCompoundCompletion();
    setState(() {});
  }

  void checkCompoundCompletion() async {
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
      compoundFound(compound.name);
      attemptsWatcher.resetAttempts();
      setState(() {});
      if (poolGameLevel.isLevelFinished()) {
        updateGameToNewLevel(levelNumber + 1);
      }
    }
  }

  void compoundFound(String compoundName) {
    emitWordCompletionEvent(compoundName);

    // Do not update the state here, to avoid inconsistencies in the UI
    resetSelection(SelectionType.modifier, updateState: false);
    resetSelection(SelectionType.head, updateState: false);
  }

  void emitWordCompletionEvent(String word) {
    wordCompletionEventStream.sink.add(word);
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

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: isLoading
          ? null
          : TopRow(
              onBackPressed: () {
                Navigator.pop(context);
              },
              displayedDifficulty: poolGameLevel.displayedDifficulty,
              levelNumber: levelNumber,
              levelProgress: poolGameLevel.getLevelProgress(),
              starCount: 4200,
            ),
      backgroundColor: customColors.background2,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: CombinationArea(
                      selectedModifier: getSelectedModifierInfo(),
                      selectedHead: getSelectedHeadInfo(),
                      onResetSelection: resetSelection,
                      maxAttempts: attemptsWatcher.maxAttempts,
                      attemptsLeft: attemptsWatcher.attemptsLeft,
                      wordCompletionEventStream:
                          wordCompletionEventStream.stream,
                    ),
                  ),
                  BottomContent(
                    onToggleSelection: toggleSelection,
                    componentInfos: getComponentInfos(),
                    hiddenComponentsCount:
                        poolGameLevel.hiddenComponents.length,
                    hintButtonInfo: MyIconButtonInfo(
                      icon: FontAwesomeIcons.lightbulb,
                      onPressed: () {
                        poolGameLevel.requestHint();
                        setState(() {});
                      },
                      enabled: poolGameLevel.canRequestHint(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class ComponentInfo {
  final UniqueComponent component;
  final SelectionType? selectionType;
  final Hint? hint;

  ComponentInfo(this.component, this.selectionType, this.hint);
}

// enum for SelectionType to be either modifier or head
enum SelectionType {
  modifier,
  head;
}
