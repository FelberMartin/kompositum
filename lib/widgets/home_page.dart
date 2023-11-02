import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/level_provider.dart';

import '../compound_pool_generator.dart';
import '../data/compound.dart';
import '../pool_game_level.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.levelProvider});

  final String title;
  final LevelProvider levelProvider;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {

  late LevelProvider _levelProvider;
  late PoolGameLevel _poolGameLevel;

  int levelNumber = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initComponents();
  }

  Future<void> initComponents() async {
    _levelProvider = widget.levelProvider;
    isLoading = true;
    levelNumber = 1;
    // print("Initializing database");
    // final databaseInitializer = DatabaseInitializer(CompoundOrigin("assets/filtered_compounds.csv"));
    // final databaseInterface = DatabaseInterface(databaseInitializer);
    // final compoundPoolGenerator = CompoundPoolGenerator(databaseInterface);
    // _levelProvider = BasicLevelProvider(compoundPoolGenerator);

    updateGameToNewLevel();
  }

  void updateGameToNewLevel() async {
    setState(() {
      isLoading = true;
    });
    print("Generating new pool for new level");
    final compounds = await _levelProvider.generateCompoundPool(levelNumber);
    print("Finished new pool for new level");
    _poolGameLevel = PoolGameLevel(compounds);
    setState(() {
      isLoading = false;
    });
  }

  Map<SelectionType, int> selectionTypeToIndex = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  String? get selectedModifier =>
      selectionTypeToIndex[SelectionType.modifier] !=
          -1
          ? _poolGameLevel.shownComponents[
      selectionTypeToIndex[SelectionType.modifier]!]
          : null;

  String? get selectedHead => selectionTypeToIndex[SelectionType.head] != -1
      ? _poolGameLevel.shownComponents[selectionTypeToIndex[SelectionType.head]!]
      : null;

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
      final compound =
      _poolGameLevel.getCompoundIfExisting(selectedModifier!, selectedHead!);
      if (compound != null) {
        compoundFound(compound.name);
        _poolGameLevel.removeCompoundFromShown(compound);
        setState(() {});
        if (_poolGameLevel.isLevelFinished()) {
          levelNumber++;
          updateGameToNewLevel();
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

  final StreamController<String> wordCompletionEventStream =
  StreamController<String>.broadcast();

  @override
  void dispose() {
    wordCompletionEventStream.close();
    super.dispose();
  }

  void emitWordCompletionEvent(String word) {
    wordCompletionEventStream.sink.add(word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoading ? CircularProgressIndicator(

        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16.0),
            // A text in a circle indicating the current score
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: 30,
              child: Text(
                levelNumber.toString(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            AnimatedTextFadeOut(textStream: wordCompletionEventStream.stream),

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
                        })
                ],
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
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

  String _displayText = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      reverseDuration: const Duration(seconds: 1),
    );

    _alignAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.topCenter,   // Changed because the controller is reversed
      end: Alignment.bottomCenter,
    ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.decelerate.flipped,
        )
    );

    widget.textStream.listen((text) {
      _displayText = text;
      _controller.reverse(from: 1.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.textStream.drain();
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
        )
    );
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
  });

  final String text;
  final SelectionType? selectionType;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selectionType != null,
      onSelected: onSelectionChanged,
      showCheckmark: false,
      selectedColor: selectionType == SelectionType.modifier
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.secondaryContainer,
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