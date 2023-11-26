import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/main.dart';
import 'package:kompositum/theme.dart';
import 'package:kompositum/widgets/buttons.dart';
import 'package:kompositum/widgets/topbar.dart';

import '../game/hints/hint.dart';
import '../game/level_provider.dart';
import '../game/pool_game_level.dart';
import '../locator.dart';
import 'icon_button.dart';

class GamePage extends StatefulWidget {
  const GamePage(
      {super.key,
      required this.title,
      required this.levelProvider,
      required this.poolGenerator,
      required this.keyValueStore,
      required this.swappableDetector
      });

  final String title;
  final LevelProvider levelProvider;
  final CompoundPoolGenerator poolGenerator;
  final KeyValueStore keyValueStore;
  final SwappableDetector swappableDetector;

  @override
  State<GamePage> createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  late final LevelProvider _levelProvider = widget.levelProvider;
  late final CompoundPoolGenerator _poolGenerator = widget.poolGenerator;
  late final SwappableDetector _swappableDetector = widget.swappableDetector;
  late final KeyValueStore _keyValueStore = widget.keyValueStore;
  late PoolGameLevel _poolGameLevel;

  late int levelNumber;
  bool isLoading = true;

  final StreamController<String> wordCompletionEventStream =
      StreamController<String>.broadcast();

  Map<SelectionType, int> selectionTypeToIndex = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  String? get selectedModifier =>
      selectionTypeToIndex[SelectionType.modifier] !=
              -1
          ? _poolGameLevel
              .shownComponents[selectionTypeToIndex[SelectionType.modifier]!]
          : null;

  String? get selectedHead => selectionTypeToIndex[SelectionType.head] != -1
      ? _poolGameLevel
          .shownComponents[selectionTypeToIndex[SelectionType.head]!]
      : null;

  @override
  void initState() {
    super.initState();
    _keyValueStore.getLevel().then((value) {
      levelNumber = value;
      updateGameToNewLevel(levelNumber);
    });
    _keyValueStore.getBlockedCompoundNames().then((value) {
      _poolGenerator.setBlockedCompounds(value);
    });
  }

  void updateGameToNewLevel(int newLevelNumber) async {
    _keyValueStore.storeLevel(newLevelNumber);
    // Save the blocked compounds BEFORE the generation of the new level,
    // so that when regenerating the same level later, the same compounds
    // are blocked.
    _keyValueStore.storeBlockedCompounds(_poolGenerator.getBlockedCompounds());
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      isLoading = true;
    });
    levelNumber = newLevelNumber;
    print("Generating new pool for new level");
    final levelSetup = _levelProvider.generateLevelSetup(levelNumber);
    final compounds = await _poolGenerator.generateFromLevelSetup(levelSetup);
    final swappables = await _swappableDetector.getSwappables(compounds);
    print("Finished new pool for new level");
    _poolGameLevel = PoolGameLevel(compounds,
        maxShownComponentCount: levelSetup.maxShownComponentCount,
        displayedDifficulty: levelSetup.displayedDifficulty,
        swappableCompounds: swappables,
    );
    setState(() {
      isLoading = false;
    });
  }

  SelectionType? getSelectionTypeForIndex(int index) {
    for (MapEntry<SelectionType, int> entry in selectionTypeToIndex.entries) {
      final selectionType = entry.key;
      final selectedIndex = entry.value;
      if (selectedIndex == index) {
        return selectionType;
      }
    }
    return null;
  }

  void resetSelection(SelectionType selectionType, {bool updateState = true}) {
    selectionTypeToIndex[selectionType] = -1;
    if (updateState) {
      setState(() {});
    }
  }

  void toggleSelection(int index) async {
    final selectionType = getSelectionTypeForIndex(index);
    if (selectionType != null) {
      selectionTypeToIndex[selectionType] = -1;
    } else if (selectionTypeToIndex[SelectionType.modifier] == -1) {
      selectionTypeToIndex[SelectionType.modifier] = index;
    } else {
      selectionTypeToIndex[SelectionType.head] = index;
    }
    checkCompoundCompletion();
    setState(() {});
  }

  void checkCompoundCompletion() async {
    if (selectedModifier != null && selectedHead != null) {
      final compound = _poolGameLevel.getCompoundIfExisting(
          selectedModifier!, selectedHead!);
      if (compound != null) {
        compoundFound(compound.name);
        _poolGameLevel.removeCompoundFromShown(compound);
        setState(() {});
        if (_poolGameLevel.isLevelFinished()) {
          updateGameToNewLevel(levelNumber + 1);
        }
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

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Scaffold(
      appBar: isLoading ? null : TopRow(
        onBackPressed: () {
          Navigator.pop(context);
        },
        displayedDifficulty: _poolGameLevel.displayedDifficulty,
        levelNumber: levelNumber,
        levelProgress: _poolGameLevel.getLevelProgress(),
        starCount: 4200,
      ),
      backgroundColor: customColors.background2,
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // TopRow(
                  //   onBackPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   displayedDifficulty: _poolGameLevel.displayedDifficulty,
                  //   levelNumber: levelNumber,
                  //   levelProgress: _poolGameLevel.getLevelProgress(),
                  //   starCount: 4200,
                  // ),
                  AnimatedTextFadeOut(
                      textStream: wordCompletionEventStream.stream),

                  // A row containing the selected modifier and head separated by a plus icon
                  CompoundMergeRow(
                      selectedModifier: selectedModifier,
                      selectedHead: selectedHead,
                      onResetSelection: resetSelection),
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final (index, component)
                            in _poolGameLevel.shownComponents.indexed)
                          WordWrapper(
                              text: component,
                              selectionType: getSelectionTypeForIndex(index),
                              onSelectionChanged: (selected) {
                                toggleSelection(index);
                              },
                              hint: _poolGameLevel.hints
                                  .firstWhereOrNull((hint) =>
                                      hint.hintedComponent == component)
                                  ?.type),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  HiddenComponentsIndicator(
                      hiddenComponentsCount:
                          _poolGameLevel.hiddenComponents.length),
                ],
              ),
      ),
    );
  }
}

class TopRow extends StatelessWidget implements PreferredSizeWidget {
  const TopRow({
    super.key,
    required this.onBackPressed,
    required this.displayedDifficulty,
    required this.levelNumber,
    required this.levelProgress,
    required this.starCount,
  });

  final VoidCallback onBackPressed;
  final Difficulty displayedDifficulty;
  final int levelNumber;
  final double levelProgress;
  final int starCount;


  @override
  Size get preferredSize => Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return MyAppBar(
      leftContent: SizedBox(
        height: 55.0,
        child: MyIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: onBackPressed,
        ),
      ),
      middleContent: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            "Level $levelNumber",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 4.0),
          Text(
            displayedDifficulty.toUiString().toLowerCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: customColors.textSecondary,
            ),
          ),
        ],
      ),
      rightContent: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            starCount.toString(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Icon(
            Icons.star_rounded,
            color: customColors.star,
          ),
          SizedBox(width: 16.0),
        ],
      ),
    );
  }
}

class HiddenComponentsIndicator extends StatelessWidget {
  const HiddenComponentsIndicator({
    super.key,
    required this.hiddenComponentsCount,
  });

  final int hiddenComponentsCount;

  @override
  Widget build(BuildContext context) {
    if (hiddenComponentsCount == 0) {
      return Container();
    }
    return Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
        child: Chip(
          label: SizedBox(
            width: 40,
            child: Center(
              child: Text(
                "$hiddenComponentsCount",
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ));
  }
}

class AnimatedTextFadeOut extends StatefulWidget {
  const AnimatedTextFadeOut({super.key, required this.textStream});

  final Stream<String> textStream;

  @override
  AnimatedTextFadeOutState createState() => AnimatedTextFadeOutState();
}

class AnimatedTextFadeOutState extends State<AnimatedTextFadeOut>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<AlignmentGeometry> _alignAnimation;
  late CurvedAnimation curve;
  late StreamSubscription<String> _textStreamSubscription;

  String _displayText = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      reverseDuration: const Duration(seconds: 1),
    );

    _alignAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.topCenter, // Changed because the controller is reversed
      end: Alignment.bottomCenter,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate.flipped,
    ));

    _textStreamSubscription = widget.textStream.listen((text) {
      _displayText = text;
      _controller.reverse(from: 1.0);
    });
  }

  @override
  void dispose() {
    _textStreamSubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: AlignTransition(
          alignment: _alignAnimation,
          child: FadeTransition(
            opacity: _controller,
            child: Text(
              _displayText,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
        ));
  }
}

class CompoundMergeRow extends StatelessWidget {
  const CompoundMergeRow({
    super.key,
    required this.selectedModifier,
    required this.selectedHead,
    required this.onResetSelection,
  });

  final String? selectedModifier;
  final String? selectedHead;
  final void Function(SelectionType) onResetSelection;

  final _placeholder = "       ";

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerRight,
            child: MyPrimaryTextButtonLarge(
              onPressed: () {
                onResetSelection(SelectionType.modifier);
              },
              text: selectedModifier ?? _placeholder,
            ),
          ),
        ),
        Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerLeft,
            child: MyPrimaryTextButtonLarge(
              onPressed: () {
                onResetSelection(SelectionType.head);
              },
              text: selectedHead ?? _placeholder,
            ),
          ),
        ),
      ],
    );
  }
}

class WordWrapper extends StatelessWidget {
  const WordWrapper({
    super.key,
    required this.text,
    required this.selectionType,
    required this.onSelectionChanged,
    this.hint,
  });

  final String text;
  final SelectionType? selectionType;
  final ValueChanged<bool> onSelectionChanged;
  final HintComponentType? hint;

  final hintColor = const Color.fromARGB(255, 243, 233, 177);

  @override
  Widget build(BuildContext context) {
    final isSelected = selectionType != null;
    if (isSelected) {
      return MyPrimaryTextButton(
        onPressed: () {
          onSelectionChanged(false);
        },
        text: text,
      );
    } else {
      return MySecondaryTextButton(
        onPressed: () {
          onSelectionChanged(true);
        },
        text: text,
      );
    }
  }
}

// enum for SelectionType to be either modifier or head
enum SelectionType {
  modifier,
  head;
}
