import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'compound.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // A list of compounds with random german compounds
  final List<Compound> compounds = [
    const Compound(name: 'Krankenhaus', modifier: 'krank', head: 'Haus'),
    const Compound(name: 'Apfelbaum', modifier: 'Apfel', head: 'Baum'),
    const Compound(name: 'Türschloss', modifier: 'Tür', head: 'Schloss'),
    const Compound(name: 'Hundehütte', modifier: 'Hund', head: 'Hütte'),
    const Compound(name: 'Küchentisch', modifier: 'Küche', head: 'Tisch'),
  ];

  List<String> getAllCompoundComponents() {
    final List<String> allComponents = [];
    for (final Compound compound in compounds) {
      allComponents.addAll(compound.getComponents());
    }
    return allComponents;
  }

  Map<SelectionType, int> selectionTypeToIndex = {
    SelectionType.modifier: -1,
    SelectionType.head: -1,
  };

  String? get selectedModifier =>
      selectionTypeToIndex[SelectionType.modifier] !=
              -1
          ? getAllCompoundComponents()[
              selectionTypeToIndex[SelectionType.modifier]!]
          : null;

  String? get selectedHead => selectionTypeToIndex[SelectionType.head] != -1
      ? getAllCompoundComponents()[selectionTypeToIndex[SelectionType.head]!]
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

  void resetSelection(SelectionType selectionType) {
    selectionTypeToIndex[selectionType] = -1;
    setState(() {});
  }

  void toggleSelection(int index) {
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

  void checkCompoundCompletion() {
    if (selectedModifier != null && selectedHead != null) {
      final compound = compounds.firstWhereOrNull((element) =>
          element.modifier == selectedModifier && element.head == selectedHead);
      if (compound != null) {
        compoundFound(compound);
      }
    }
  }

  void compoundFound(Compound compound) {
    emitWordCompletionEvent(compound.name);
    resetSelection(SelectionType.modifier);
    resetSelection(SelectionType.head);
    compounds.remove(compound);
    compounds.add(compound);  // For testing purposes
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
    print("emitWordCompletionEvent: $word");
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
                      in getAllCompoundComponents().indexed)
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
