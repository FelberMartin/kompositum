import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/swappable_detector.dart';

import '../data/compound.dart';
import 'hints/hint.dart';


abstract class GameLevel {

  final shownComponents = <String>[];
  final hiddenComponents = <String>[];
  final _allCompounds = <Compound>[];

  final hints = <Hint>[];

  void removeCompoundFromShown(Compound compound);

  Compound? getCompoundIfExisting(String modifier, String head) {
    final originalCompound = _allCompounds.firstWhereOrNull(
            (compound) => compound.modifier == modifier && compound.head == head);
    return originalCompound;
  }

  bool isLevelFinished() {
    return shownComponents.isEmpty;
  }

  bool canRequestHint() {
    return hints.length < 2;
  }

  void requestHint() {
    if (canRequestHint()) {
      final hint = generateHint();
      hints.add(hint);
      print("Hint: ${hint.hintedComponent} (${hint.type})");
    }
  }

  Hint generateHint() {
    return Hint.generate(_allCompounds, shownComponents, hints);
  }

  double getLevelProgress();

}

class PoolGameLevel extends GameLevel {
  final int maxShownComponentCount;

  final _unsolvedCompounds = <Compound>[];

  final Difficulty displayedDifficulty;

  PoolGameLevel(
      List<Compound> allCompounds,
      { this.maxShownComponentCount = 11,
        this.displayedDifficulty = Difficulty.easy,
      }) {
    _allCompounds.addAll(allCompounds);
    _unsolvedCompounds.addAll(allCompounds);
    hiddenComponents
        .addAll(allCompounds.expand((compound) => compound.getComponents()));
    _fillShownComponents();
  }

  void _fillShownComponents() {
    final toFillCount = maxShownComponentCount - shownComponents.length;
    for (var i = 0; i < toFillCount; i++) {
      if (hiddenComponents.isEmpty) {
        break;
      }
      final nextComponent = getNextShownComponent(seed: 0);
      shownComponents.add(nextComponent);
      hiddenComponents.remove(nextComponent);
    }
  }

  void removeCompoundFromShown(Compound compound) {
    final compoundToRemove = _findCompoundToRemove(compound);
    if (compoundToRemove == null) {
      return;
    }
    _removeHintsForCompound(compoundToRemove);
    shownComponents.remove(compoundToRemove.modifier);
    shownComponents.remove(compoundToRemove.head);
    _unsolvedCompounds.remove(compoundToRemove);
    _fillShownComponents();
  }

  Compound? _findCompoundToRemove(Compound compound) {
    Compound? compoundToRemove = _allCompounds.firstWhereOrNull((comp) => comp == compound);
    return compoundToRemove;
  }

  void _removeHintsForCompound(Compound compound) {
    hints.removeWhere((hint) =>
        (hint.type == HintComponentType.modifier &&
            hint.hintedComponent == compound.modifier) ||
        (hint.type == HintComponentType.head &&
            hint.hintedComponent == compound.head));
  }

  String getNextShownComponent({int? seed}) {
    final random = seed == null ? Random() : Random(seed);
    final refillCount = maxShownComponentCount - shownComponents.length;
    if (refillCount > 1 || _isCompoundInShownComponents()) {
      return hiddenComponents[random.nextInt(hiddenComponents.length)];
    }

    return _findMissingComponentForRandomCompound(random);
  }

  bool _isCompoundInShownComponents() {
    for (Compound compound in _allCompounds) {
      if (shownComponents.contains(compound.modifier) &&
          shownComponents.contains(compound.head)) {
        return true;
      }
    }
    return false;
  }

  String _findMissingComponentForRandomCompound(Random random) {
    final compundsCurrentlyCompletable = _unsolvedCompounds
        .where((compound) =>
            shownComponents.contains(compound.modifier) ||
            shownComponents.contains(compound.head))
        .toList();
    final compound = compundsCurrentlyCompletable[
        random.nextInt(compundsCurrentlyCompletable.length)];
    if (shownComponents.contains(compound.modifier)) {
      return compound.head;
    } else {
      return compound.modifier;
    }
  }

  @override
  double getLevelProgress() {
    return 1 - _unsolvedCompounds.length / _allCompounds.length;
  }
}

class SentenceGameLevel extends GameLevel {

  final String sentence;
  final List<String> sentenceComponents;
  final String separator;

  SentenceGameLevel(this.sentence, this.sentenceComponents, this.separator) {
    final sentenceComponentsToAssign = sentenceComponents.toList();
    while (shownComponents.length < 11) {
      if (sentenceComponentsToAssign.isEmpty) {
        break;
      }
      shownComponents.add(sentenceComponentsToAssign.removeAt(Random().nextInt(sentenceComponentsToAssign.length)));
    }
    for (final component in sentenceComponentsToAssign) {
      hiddenComponents.add(component);
    }

    for (int i = 0; i < sentenceComponents.length - 1; i++) {
      final modifier = sentenceComponents[i];
      final head = sentenceComponents[i + 1];
      final compound = Compound(name: "$modifier$separator$head", modifier: modifier, head: head);
      _allCompounds.add(compound);
    }
  }

  @override
  double getLevelProgress() {
    final remaining = shownComponents.length + hiddenComponents.length;
    final total = sentenceComponents.length;
    return 1 - remaining / total;
  }

  @override
  void removeCompoundFromShown(Compound compound) {
    final compoundToRemove = _findCompoundToRemove(compound);
    if (compoundToRemove == null) {
      return;
    }
    _removeHintsForCompound(compoundToRemove);
    shownComponents.remove(compoundToRemove.modifier);
    shownComponents.remove(compoundToRemove.head);

    if (shownComponents.isEmpty) {
      return;
    }

    // Add the component and the new resulting compounds
    final newComponent = compoundToRemove.name;
    _addNewCompounds(newComponent);
    shownComponents.insert(0, newComponent);


    // Fill up with a new component
    if (hiddenComponents.isNotEmpty) {
      final nextComponent = hiddenComponents.removeAt(Random().nextInt(hiddenComponents.length));
      shownComponents.add(nextComponent);
    }
  }

  void _addNewCompounds(String newComponent) {
    final allComponents = shownComponents + hiddenComponents;
    for (final component in allComponents) {
      final newCompound1 = "$component$separator$newComponent";
      if (sentence.contains(newCompound1)) {
        _allCompounds.add(Compound(name: newCompound1, modifier: component, head: newComponent));
      }
      final newCompound2 = "$newComponent$separator$component";
      if (sentence.contains(newCompound2)) {
        _allCompounds.add(Compound(name: newCompound2, modifier: newComponent, head: component));
      }
    }
  }

  Compound? _findCompoundToRemove(Compound compound) {
    Compound? compoundToRemove = _allCompounds.firstWhereOrNull((comp) => comp == compound);
    return compoundToRemove;
  }

  void _removeHintsForCompound(Compound compound) {
    hints.removeWhere((hint) =>
    (hint.type == HintComponentType.modifier &&
        hint.hintedComponent == compound.modifier) ||
        (hint.type == HintComponentType.head &&
            hint.hintedComponent == compound.head));
  }

}
