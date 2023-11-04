import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically

import '../data/compound.dart';

class PoolGameLevel {
  final Random random = Random();

  final int maxShownComponentCount;

  final _allCompounds = <Compound>[];
  final _unsolvedCompounds = <Compound>[];
  final shownComponents = <String>[];
  final hiddenComponents = <String>[];

  PoolGameLevel(List<Compound> allCompounds, {this.maxShownComponentCount = 10}) {
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
      final nextComponent = getNextShownComponent();
      shownComponents.add(nextComponent);
      hiddenComponents.remove(nextComponent);
    }
  }

  void removeCompoundFromShown(Compound compound) {
    shownComponents.remove(compound.modifier);
    shownComponents.remove(compound.head);
    _unsolvedCompounds.remove(compound);
    _fillShownComponents();
  }

  Compound? getCompoundIfExisting(String modifier, String head) {
    return _allCompounds.firstWhereOrNull(
        (compound) => compound.modifier == modifier && compound.head == head);
  }

  bool isLevelFinished() {
    return shownComponents.isEmpty;
  }

  String getNextShownComponent() {
    final refillCount = maxShownComponentCount - shownComponents.length;
    if (refillCount > 1 || _isCompoundInShownComponents()) {
      return hiddenComponents[random.nextInt(hiddenComponents.length)];
    }

    return _findMissingComponentForRandomCompound();
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

  String _findMissingComponentForRandomCompound() {
    final compundsCurrentlyCompletable = _unsolvedCompounds.where((compound) =>
        shownComponents.contains(compound.modifier) ||
        shownComponents.contains(compound.head)).toList();
    final compound = compundsCurrentlyCompletable[
        random.nextInt(compundsCurrentlyCompletable.length)];
    if (shownComponents.contains(compound.modifier)) {
      return compound.head;
    } else {
      return compound.modifier;
    }
  }
}
