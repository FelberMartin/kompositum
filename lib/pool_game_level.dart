import 'dart:math';

import 'package:kompositum/compound_pool_generator.dart';

import 'data/compound.dart';

class PoolGameLevel {
  final Random random = Random();

  final CompoundPoolGenerator poolGenerator;
  final int initialCompoundCount;
  final int maxShownComponentCount;
  final CompactFrequencyClass frequencyClass = CompactFrequencyClass.easy;

  final _allCompounds = <Compound>[];
  final _unsolvedCompounds = <Compound>[];
  final shownComponents = <String>[];
  final hiddenComponents = <String>[];

  PoolGameLevel(
      {required this.poolGenerator,
      required this.initialCompoundCount,
      this.maxShownComponentCount = 10}) {}

  Future<void> init() async {
    poolGenerator
        .generate(
            frequencyClass: frequencyClass, compoundCount: initialCompoundCount)
        .then((compounds) {
      _allCompounds.addAll(compounds);
      _unsolvedCompounds.addAll(compounds);
      hiddenComponents
          .addAll(compounds.expand((compound) => compound.getComponents()));
      _fillShownComponents();
    });
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

  void checkCompound(String modifier, String head) {
    if (_isCorrectCompound(modifier, head)) {
      shownComponents.remove(modifier);
      shownComponents.remove(head);
      _unsolvedCompounds.removeWhere(
          (compound) => compound.modifier == modifier && compound.head == head);
      _fillShownComponents();
    }
  }

  bool _isCorrectCompound(String modifier, String head) {
    return _allCompounds.any(
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
