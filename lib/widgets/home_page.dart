import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:kompositum/data/database_initializer.dart';

import '../data/compound.dart';
import '../data/data_source.dart';

final datasource = MockDatabase();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int maxFrequencyClass = 18;
  final List<String> components = [];

  int score = 0;


  @override
  void initState() {
    super.initState();
    initComponents();
  }

  Future<void> initComponents() async {
    // Print the number of compounds in the database
    final compounds = await datasource.getAllCompounds();
    print("Number of compounds: ${compounds.length}");
    print("Number of compounds with sql: ${await datasource.countCompounds()}");


    final List<String> unshuffledComponents = [];
    for (var i = 0; i < 5; i++) {
      final compound = await datasource.getRandomCompound(maxFrequencyClass);
      if (compound != null) {
        unshuffledComponents.add(compound.modifier);
        unshuffledComponents.add(compound.head);
        print("Added compound: $compound");
      }
    }
    unshuffledComponents.shuffle();
    components.addAll(unshuffledComponents);
    setState(() {});
  }

  Map<SelectionType, int> selectionTypeToIndex = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  String? get selectedModifier =>
      selectionTypeToIndex[SelectionType.modifier] !=
          -1
          ? components[
      selectionTypeToIndex[SelectionType.modifier]!]
          : null;

  String? get selectedHead => selectionTypeToIndex[SelectionType.head] != -1
      ? components[selectionTypeToIndex[SelectionType.head]!]
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
      final compound = await datasource.getCompound(selectedModifier!, selectedHead!);
      if (compound != null) {
        compoundFound(compound);
      }
    }
  }

  void compoundFound(Compound compound) {
    score++;
    emitWordCompletionEvent(compound.name);

    // Without caching here, the selectedHead would be invalid after removing
    // the selectedModifier.
    final cachedSelectedHead = selectedHead;
    components.remove(selectedModifier);
    components.remove(cachedSelectedHead);

    // Do not update the state here, to avoid inconsistencies in the UI
    resetSelection(SelectionType.modifier, updateState: false);
    resetSelection(SelectionType.head, updateState: false);

    addNewComponents();
  }

  void addNewComponents() async {
    final List<String> newComponents = [];
    final compound = await datasource.getRandomCompound(maxFrequencyClass);
    if (compound != null) {
      newComponents.add(compound.modifier);
      newComponents.add(compound.head);
    }

    components.addAll(newComponents);
    setState(() {});
  }

  final StreamController<String> wordCompletionEventStream =
  StreamController<String>();

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16.0),
            // A text in a circle indicating the current score
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: 30,
              child: Text(
                score.toString(),
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
                  in components.indexed)
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