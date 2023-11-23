import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/advent_day.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';

import '../game/hints/hint.dart';
import '../game/level_provider.dart';
import '../game/pool_game_level.dart';
import '../locator.dart';

class GamePage extends StatefulWidget {
  const GamePage(
      {super.key,
      required this.adventDay,
      });

  final AdventDay adventDay;

  @override
  State<GamePage> createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  late final KeyValueStore _keyValueStore = locator<KeyValueStore>();
  late final AdventDay _adventDay = widget.adventDay;
  late GameLevel _gameLevel = _adventDay.levelConfigs[0].getLevel();

  int gameLevelIndex = 0;
  bool isLoading = false;

  final StreamController<String> wordCompletionEventStream =
      StreamController<String>.broadcast();

  Map<SelectionType, int> selectionTypeToIndex = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  String? get selectedModifier =>
      selectionTypeToIndex[SelectionType.modifier] !=
              -1
          ? _gameLevel
              .shownComponents[selectionTypeToIndex[SelectionType.modifier]!]
          : null;

  String? get selectedHead => selectionTypeToIndex[SelectionType.head] != -1
      ? _gameLevel
          .shownComponents[selectionTypeToIndex[SelectionType.head]!]
      : null;

  @override
  void initState() {
    super.initState();
  }

  void updateGameToNewLevel(int newLevelIndex) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    setState(() {
      isLoading = true;
    });
    if (newLevelIndex >= _adventDay.levelConfigs.length) {
      // Set the advent day as completed
      final adventCompleted = await _keyValueStore.getAdventCompleted();
      adventCompleted[_adventDay.day - 1] = true;
      await _keyValueStore.storeAdventCompleted(adventCompleted);
      Navigator.of(context).pop();
      return;
    }
    gameLevelIndex = newLevelIndex;
    _gameLevel = _adventDay.levelConfigs[newLevelIndex].getLevel();
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
      final compound = _gameLevel.getCompoundIfExisting(
          selectedModifier!, selectedHead!);
      if (compound != null) {
        compoundFound(compound.name);
        _gameLevel.removeCompoundFromShown(compound);
        setState(() {});
        if (_gameLevel.isLevelFinished()) {
          updateGameToNewLevel(gameLevelIndex + 1);
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
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 221, 233, 239),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 16.0),
                  TopRow(
                      title: "Tag ${_adventDay.day}",
                      subtitle: "Teil ${gameLevelIndex + 1}",
                      levelProgress: _gameLevel.getLevelProgress(),
                      isHintAvailable: _gameLevel.canRequestHint(),
                      onHintPressed: () {
                        _gameLevel.requestHint();
                        setState(() {});
                      }),

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
                            in _gameLevel.shownComponents.indexed)
                          WordWrapper(
                              text: component,
                              selectionType: getSelectionTypeForIndex(index),
                              onSelectionChanged: (selected) {
                                toggleSelection(index);
                              },
                              hint: _gameLevel.hints
                                  .firstWhereOrNull((hint) =>
                                      hint.hintedComponent == component)
                                  ?.type),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                  HiddenComponentsIndicator(
                      hiddenComponentsCount:
                          _gameLevel.hiddenComponents.length),
                ],
              ),
      ),
    );
  }
}

class TopRow extends StatelessWidget {
  const TopRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.levelProgress,
    required this.isHintAvailable,
    required this.onHintPressed,
  });

  final String title;
  final String subtitle;
  final double levelProgress;
  final bool isHintAvailable;
  final Function onHintPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Expanded(child:
          Text(
            subtitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
            child: Align(
          alignment: Alignment.center,
          // Add a loading indicator around the circle avatar, indicating the current level progress
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                radius: 30,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              Center(
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: levelProgress > 0 ? levelProgress : 0.03,
                    strokeWidth: 5,
                  ),
                ),
              ),
        ]),
        )),
        Expanded(
            child: Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            onPressed: isHintAvailable
                ? () {
                    onHintPressed();
                  }
                : null,
            child: Text("Hinweis"),
          ),
        ))
      ]),
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
      reverseDuration: const Duration(seconds: 2),
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
      _controller.reverseDuration = Duration(milliseconds: 1000 + text.length * 100);
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child:Text(
                _displayText,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: ActionChip(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            label: Text(
              selectedModifier ?? ' ',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            onPressed: () {
              onResetSelection(SelectionType.modifier);
            },
          ),
        ),
        const Icon(Icons.add),
        Expanded(
          flex: 1,
          child: ActionChip(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            label: Text(
              selectedHead ?? ' ',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            onPressed: () {
              onResetSelection(SelectionType.head);
            },
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
    return FilterChip(
      selected: selectionType != null,
      onSelected: onSelectionChanged,
      showCheckmark: false,
      selectedColor: selectionType == SelectionType.modifier
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.secondaryContainer,
      elevation: hint != null ? 6.0 : 0.0,
      backgroundColor:
          hint != null ? hintColor : Theme.of(context).colorScheme.background,
      shadowColor: hintColor,
      selectedShadowColor: hintColor,
      label: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

// enum for SelectionType to be either modifier or head
enum SelectionType {
  modifier,
  head;
}
