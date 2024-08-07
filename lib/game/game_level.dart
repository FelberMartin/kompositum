import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:flutter/cupertino.dart';
import 'package:kompositum/config/star_costs_rewards.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/attempts_watcher.dart';
import 'package:kompositum/game/difficulty.dart';
import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/level_content.dart';
import 'package:kompositum/game/swappable_detector.dart';


abstract class GameLevel {

  @protected
  final int maxHintCount = 2;

  final int maxShownComponentCount;
  final int minSolvableCompoundsInPool;

  @protected
  final allCompounds = <Compound>[];
  @protected
  final unsolvedCompounds = <Compound>[];
  final List<Swappable> swappableCompounds;

  final shownComponents = <UniqueComponent>[];
  final hiddenComponents = <UniqueComponent>[];

  final hints = <Hint>[];

  late AttemptsWatcher attemptsWatcher;

  GameLevel({
    this.maxShownComponentCount = 9,
    this.minSolvableCompoundsInPool = 1,
    this.swappableCompounds = const [],
  }) {
    attemptsWatcher = AttemptsWatcher();
  }

  void initialize({
    required compounds,
    required List<UniqueComponent> selectableComponents,
  }) {
    allCompounds.addAll(compounds);
    unsolvedCompounds.addAll(compounds);
    hiddenComponents.addAll(selectableComponents);
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
    // There was weird bug where 3 components were removed, to potentially fix it, I added this check
    if (!modifier.matches(compound.modifier) || !head.matches(compound.head)) {
      return;
    }
    _removeHintsForCompound(compoundToRemove);
    shownComponents.remove(modifier);
    shownComponents.remove(head);
    unsolvedCompounds.remove(compoundToRemove);
    _fillShownComponents();
  }

  Compound? _findCompoundToRemove(Compound compound) {
    Compound? compoundToRemove =
    allCompounds.firstWhereOrNull((comp) => comp == compound);
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
          hint.hintedComponent.matches(compound.modifier)) ||
      (hint.type == HintComponentType.head &&
          hint.hintedComponent.matches(compound.head))
    );
  }

  Compound? checkForCompound(String modifier, String head) {
    final compound = getCompoundIfExisting(modifier, head);
    if (compound == null) {
      attemptsWatcher.attemptUsed(modifier, head);
    } else {
      attemptsWatcher.resetLocalAttempts();
    }
    return compound;
  }

  Compound? getCompoundIfExisting(String modifier, String head) {
    final originalCompound = allCompounds.firstWhereOrNull(
              (compound) => compound.matches(modifier, head));
    if (originalCompound != null) {
      return originalCompound;
    }
    final swappedCompound = swappableCompounds.firstWhereOrNull((swappable) =>
            swappable.swapped.matches(modifier, head));
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
    final solvableCompounds = countNextSolvableCompoundsInPool();
    if (solvableCompounds < minSolvableCompoundsInPool && refillCount <= minSolvableCompoundsInPool) {
      return findComponentToCreateNewSolvable(random);
    }

    return hiddenComponents[random.nextInt(hiddenComponents.length)];
  }

  @protected
  int countNextSolvableCompoundsInPool();

  @protected
  UniqueComponent findComponentToCreateNewSolvable(Random random);

  Hint? requestHint(int starCount) {
    if (canRequestHint(starCount)) {
      final hint = generateHint();
      hints.add(hint);
      print("Hint: ${hint.hintedComponent} (${hint.type})");

      // There is only one free hint.
      if (Costs.freeHintAvailable) {
        Costs.freeHintAvailable = false;
      }
      return hint;
    }
    return null;
  }

  @protected
  Hint generateHint();

  bool canRequestHint(int starCount) {
    return hints.length < maxHintCount && getHintCost() <= starCount;
  }

  int getHintCost() {
    return Costs.hintCost(failedAttempts: attemptsWatcher.attemptsFailed);
  }

  double getLevelProgress() {
    return 1 - unsolvedCompounds.length / allCompounds.length;
  }
}
