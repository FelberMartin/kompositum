import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:format/format.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:kompositum/main.dart';
import 'package:kompositum/theme.dart';
import 'package:kompositum/util/clip_shadow_path.dart';
import 'package:kompositum/widgets/buttons.dart';
import 'package:kompositum/widgets/topbar.dart';

import '../game/hints/hint.dart';
import '../game/level_provider.dart';
import '../game/pool_game_level.dart';
import '../locator.dart';
import '../util/rounded_edge_clipper.dart';
import 'icon_button.dart';

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
    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      isLoading = true;
    });
    levelNumber = newLevelNumber;
    print("Generating new pool for new level");
    final levelSetup = _levelProvider.generateLevelSetup(levelNumber);
    final compounds = await _poolGenerator.generateFromLevelSetup(levelSetup);
    final swappables = await _swappableDetector.getSwappables(compounds);
    print("Finished new pool for new level");
    _poolGameLevel = PoolGameLevel(
      compounds,
      maxShownComponentCount: true ? 5 : levelSetup.maxShownComponentCount,
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

  List<ComponentInfo> getComponentInfos() {
    return _poolGameLevel.shownComponents.map((component) {
      final selectionType = getSelectionTypeForIndex(
          _poolGameLevel.shownComponents.indexOf(component));
      final hint = _poolGameLevel.hints
          .firstWhereOrNull((hint) => hint.hintedComponent == component);
      return ComponentInfo(component, selectionType, hint);
    }).toList();
  }

  ComponentInfo? getSelectedModifierInfo() {
    if (selectedModifier == null) {
      return null;
    }
    final hint = _poolGameLevel.hints
        .firstWhereOrNull((hint) => hint.hintedComponent == selectedModifier);
    return ComponentInfo(selectedModifier!, SelectionType.modifier, hint);
  }

  ComponentInfo? getSelectedHeadInfo() {
    if (selectedHead == null) {
      return null;
    }
    final hint = _poolGameLevel.hints
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
                  Expanded(
                      child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CompoundMergeRow(
                          selectedModifier: getSelectedModifierInfo(),
                          selectedHead: getSelectedHeadInfo(),
                          onResetSelection: resetSelection),
                      AnimatedTextFadeOut(
                          textStream: wordCompletionEventStream.stream),
                    ],
                  )),
                  BottomContent(
                    onToggleSelection: toggleSelection,
                    componentInfos: getComponentInfos(),
                    hiddenComponentsCount:
                        _poolGameLevel.hiddenComponents.length,
                    hintButtonInfo: MyIconButtonInfo(
                      icon: FontAwesomeIcons.lightbulb,
                      onPressed: () {
                        _poolGameLevel.requestHint();
                        setState(() {});
                      },
                      enabled: _poolGameLevel.canRequestHint(),
                    ),
                  ),
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
      leftContent: Center(
        child: MyIconButton(
          icon: FontAwesomeIcons.chevronLeft,
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
            // Format the starcount with a separator for thousands
            "{:,d}".format([starCount]),
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
    final customColors = Theme.of(context).extension<CustomColors>()!;
    if (hiddenComponentsCount == 0) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$hiddenComponentsCount",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text("verdeckte Wörter",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: customColors.textSecondary,
                ))
      ],
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
  late StreamSubscription<String> _textStreamSubscription;

  String _displayText = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      reverseDuration: const Duration(milliseconds: 1500),
    );

    _alignAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.topCenter, // Changed because the controller is reversed
      end: Alignment.center,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
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
    if (_displayText.isEmpty) {
      return Container();
    }
    return AlignTransition(
      alignment: _alignAnimation,
      child: FadeTransition(
        opacity: _controller,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _displayText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
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

  final ComponentInfo? selectedModifier;
  final ComponentInfo? selectedHead;
  final void Function(SelectionType) onResetSelection;

  final _placeholder = "    ";

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerRight,
            child: ComponentWithHint(
              hint: selectedModifier?.hint?.type,
              size: 32.0,
              button: MyPrimaryTextButtonLarge(
                onPressed: () {
                  onResetSelection(SelectionType.modifier);
                },
                text: selectedModifier?.text ?? _placeholder,
              ),
            ),
          ),
        ),
        Icon(
          FontAwesomeIcons.plus,
          color: Theme.of(context).colorScheme.primary,
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.centerLeft,
            child: ComponentWithHint(
              hint: selectedHead?.hint?.type,
              size: 32.0,
              button: MyPrimaryTextButtonLarge(
                onPressed: () {
                  onResetSelection(SelectionType.head);
                },
                text: selectedHead?.text ?? _placeholder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ComponentInfo {
  final String text;
  final SelectionType? selectionType;
  final Hint? hint;

  ComponentInfo(this.text, this.selectionType, this.hint);
}

class BottomContent extends StatelessWidget {
  const BottomContent({
    super.key,
    required this.onToggleSelection,
    required this.componentInfos,
    required this.hiddenComponentsCount,
    required this.hintButtonInfo,
  });

  final Function(int) onToggleSelection;
  final List<ComponentInfo> componentInfos;
  final int hiddenComponentsCount;
  final MyIconButtonInfo hintButtonInfo;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return ClipPath(
      clipper: RoundedEdgeClipper(onBottom: false),
      child: Container(
        height: 400,
        color: Theme.of(context).colorScheme.secondary,
        child: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  for (final (index, componentInfo) in componentInfos.indexed)
                    WordWrapper(
                      text: componentInfo.text,
                      selectionType: componentInfo.selectionType,
                      onSelectionChanged: (selected) {
                        onToggleSelection(index);
                      },
                      hint: componentInfo.hint?.type,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HiddenComponentsIndicator(
                    hiddenComponentsCount: hiddenComponentsCount,
                  ),
                  Column(
                    children: [
                      MyIconButton.fromInfo(
                        info: hintButtonInfo,
                      ),
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Text(
                            "100",
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: customColors.textSecondary,
                                ),
                          ),
                          Icon(
                            Icons.star_rounded,
                            color: customColors.star,
                            size: 16.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final isSelected = selectionType != null;
    final button = isSelected ?
      MyPrimaryTextButton(
        onPressed: () {
          onSelectionChanged(false);
        },
        text: text,
      )
    : MySecondaryTextButton(
        onPressed: () {
          onSelectionChanged(true);
        },
        text: text,
      );

      return ComponentWithHint(button: button, hint: hint);
  }
}

class ComponentWithHint extends StatelessWidget {
  const ComponentWithHint({
    super.key,
    required this.button,
    required this.hint,
    this.size = 24.0,
  });

  final StatelessWidget button;
  final HintComponentType? hint;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (hint == null) {
      return button;
    }
    return Stack(
      alignment: const Alignment(1.1, -1.2),
      children: [
        button,
        HintIndicator(
            hintType: hint!,
            size: size,
        ),
      ],
    );
  }
}



class HintIndicator extends StatelessWidget {
  const HintIndicator({
    super.key,
    required this.hintType,
    required this.size,
  });

  final HintComponentType hintType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Icon(
        FontAwesomeIcons.lightbulb,
        color: customColors.star,
        size: size * 0.6,
      ),
    );
  }
}

// enum for SelectionType to be either modifier or head
enum SelectionType {
  modifier,
  head;
}
