import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically

import '../data/compound.dart';
import 'hints/hint.dart';

class PoolGameLevel {
  final int maxShownComponentCount;

  final _allCompounds = <Compound>[];
  final _unsolvedCompounds = <Compound>[];
  final shownComponents = <String>[];
  final hiddenComponents = <String>[];

  final hints = <Hint>[];

  PoolGameLevel(List<Compound> allCompounds,
      {this.maxShownComponentCount = 11}) {
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
    _removeHintsForCompound(compound);
    shownComponents.remove(compound.modifier);
    shownComponents.remove(compound.head);
    _unsolvedCompounds.remove(compound);
    _fillShownComponents();
  }

  void _removeHintsForCompound(Compound compound) {
    hints.removeWhere((hint) =>
        (hint.type == HintComponentType.modifier &&
            hint.hintedComponent == compound.modifier) ||
        (hint.type == HintComponentType.head &&
            hint.hintedComponent == compound.head));
  }

  Compound? getCompoundIfExisting(String modifier, String head) {
    return _allCompounds.firstWhereOrNull(
        (compound) => compound.modifier == modifier && compound.head == head);
  }

  bool isLevelFinished() {
    return shownComponents.isEmpty;
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

  void requestHint() {
    if (canRequestHint()) {
      final hint = Hint.generate(_allCompounds, shownComponents, hints);
      hints.add(hint);
      print("Hint: ${hint.hintedComponent} (${hint.type})");
    }
  }

  bool canRequestHint() {
    return hints.length < 2;
  }
}
