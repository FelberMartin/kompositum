import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/swappable_detector.dart';

import '../data/models/compound.dart';
import 'hints/hint.dart';

class PoolGameLevel {
  final int maxShownComponentCount;

  final _allCompounds = <Compound>[];
  final _unsolvedCompounds = <Compound>[];
  final List<Swappable> swappableCompounds;

  final shownComponents = <UniqueComponent>[];
  final hiddenComponents = <UniqueComponent>[];

  final Difficulty displayedDifficulty;
  final hints = <Hint>[];

  PoolGameLevel(List<Compound> allCompounds,
      {this.maxShownComponentCount = 11,
      this.displayedDifficulty = Difficulty.easy,
      this.swappableCompounds = const []}) {
    _allCompounds.addAll(allCompounds);
    _unsolvedCompounds.addAll(allCompounds);
    final components = UniqueComponent.fromCompounds(allCompounds);
    hiddenComponents.addAll(components);
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

  void removeCompoundFromShown(
    Compound compound,
    UniqueComponent modifier,
    UniqueComponent head,
  ) {
    final compoundToRemove = _findCompoundToRemove(compound);
    if (compoundToRemove == null) {
      return;
    }
    _removeHintsForCompound(compoundToRemove);
    shownComponents.remove(modifier);
    shownComponents.remove(head);
    _unsolvedCompounds.remove(compoundToRemove);
    _fillShownComponents();
  }

  Compound? _findCompoundToRemove(Compound compound) {
    Compound? compoundToRemove =
        _allCompounds.firstWhereOrNull((comp) => comp == compound);
    if (compoundToRemove != null) {
      return compoundToRemove;
    }
    return swappableCompounds
        .firstWhereOrNull((swappable) => swappable.swapped == compound)
        ?.original;
  }

  void _removeHintsForCompound(Compound compound) {
    hints.removeWhere((hint) =>
        (hint.type == HintComponentType.modifier &&
            hint.hintedComponent.text == compound.modifier) ||
        (hint.type == HintComponentType.head &&
            hint.hintedComponent.text == compound.head));
  }

  Compound? getCompoundIfExisting(String modifier, String head) {
    final originalCompound = _allCompounds.firstWhereOrNull(
        (compound) => compound.modifier == modifier && compound.head == head);
    if (originalCompound != null) {
      return originalCompound;
    }
    final swappedCompound = swappableCompounds.firstWhereOrNull((swappable) =>
        swappable.swapped.modifier == modifier &&
        swappable.swapped.head == head);
    if (swappedCompound != null) {
      return swappedCompound.swapped;
    }
    return null;
  }

  bool isLevelFinished() {
    return shownComponents.isEmpty;
  }

  UniqueComponent getNextShownComponent({int? seed}) {
    final random = seed == null ? Random() : Random(seed);
    final refillCount = maxShownComponentCount - shownComponents.length;
    if (refillCount > 1 || _isCompoundInShownComponents()) {
      return hiddenComponents[random.nextInt(hiddenComponents.length)];
    }

    return _findMissingComponentForRandomCompound(random);
  }

  bool _isCompoundInShownComponents() {
    return _allCompounds
        .any((compound) => compound.isSolvedBy(shownComponents));
  }

  UniqueComponent _findMissingComponentForRandomCompound(Random random) {
    final compoundsCurrentlyCompletable = _unsolvedCompounds
        .where((compound) => compound.isOnlyPartiallySolvedBy(shownComponents))
        .toList();
    final compound = compoundsCurrentlyCompletable[
        random.nextInt(compoundsCurrentlyCompletable.length)];

    final shownComponent = shownComponents.firstWhere((component) =>
        component.text == compound.modifier || component.text == compound.head);
    return hiddenComponents.firstWhere((component) =>
        component.text == compound.modifier ||
        component.text == compound.head && component != shownComponent);
  }

  Hint? requestHint() {
    if (canRequestHint()) {
      final hint = Hint.generate(_allCompounds, shownComponents, hints);
      hints.add(hint);
      print("Hint: ${hint.hintedComponent} (${hint.type})");
      return hint;
    }
  }

  bool canRequestHint() {
    return hints.length < 2;
  }

  double getLevelProgress() {
    return 1 - _unsolvedCompounds.length / _allCompounds.length;
  }
}
