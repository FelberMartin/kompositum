import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/swappable_detector.dart';

import '../config/star_costs_rewards.dart';
import '../data/models/compound.dart';
import 'attempts_watcher.dart';
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

  late AttemptsWatcher attemptsWatcher;

  PoolGameLevel(
    List<Compound> allCompounds,
    {
      this.maxShownComponentCount = 11,
      this.displayedDifficulty = Difficulty.easy,
      this.swappableCompounds = const [],
  }) {
    _allCompounds.addAll(allCompounds);
    _unsolvedCompounds.addAll(allCompounds);
    final components = UniqueComponent.fromCompounds(allCompounds);
    hiddenComponents.addAll(components);
    _fillShownComponents();
    attemptsWatcher = AttemptsWatcher();
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
    if (compound.modifier != modifier.text || compound.head != head.text) {
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

  Compound? checkForCompound(String modifier, String head) {
    final compound = getCompoundIfExisting(modifier, head);
    if (compound == null) {
      attemptsWatcher.attemptUsed(modifier, head);
    } else {
      attemptsWatcher.resetAttempts();
    }
    return compound;
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
    if (refillCount > 1 || _isAnyCompoundInShownComponents()) {
      return hiddenComponents[random.nextInt(hiddenComponents.length)];
    }

    return _findMissingComponentForRandomCompound(random);
  }

  bool _isAnyCompoundInShownComponents() {
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

  Hint? requestHint(int starCount) {
    if (canRequestHint(starCount)) {
      final hint = Hint.generate(_allCompounds, shownComponents, hints);
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

  bool canRequestHint(int starCount) {
    return hints.length < 2 && getHintCost() <= starCount;
  }

  int getHintCost() {
    return Costs.hintCost(failedAttempts: attemptsWatcher.attemptsFailed);
  }

  double getLevelProgress() {
    return 1 - _unsolvedCompounds.length / _allCompounds.length;
  }

  static PoolGameLevel fromJson(Map<String, dynamic> json) {
    final allCompounds = (json['_allCompounds'] as List)
        .map((compound) => Compound.fromJson(compound))
        .toList();
    final unsolvedCompounds = (json['_unsolvedCompounds'] as List)
        .map((compound) => Compound.fromJson(compound))
        .toList();
    final swappableCompounds = (json['swappableCompounds'] as List)
        .map((compound) => Swappable.fromJson(compound))
        .toList();
    final shownComponents = (json['shownComponents'] as List)
        .map((component) => UniqueComponent.fromJson(component))
        .toList();
    final hiddenComponents = (json['hiddenComponents'] as List)
        .map((component) => UniqueComponent.fromJson(component))
        .toList();
    final hints = (json['hints'] as List)
        .map((hint) => Hint.fromJson(hint))
        .toList();
    final displayedDifficulty = Difficulty.values[json['displayedDifficulty'] as int];
    final maxShownComponentCount = json['maxShownComponentCount'] as int;
    final attemptsWatcher = json.containsKey('attemptsWatcher') ? AttemptsWatcher.fromJson(json['attemptsWatcher']) : AttemptsWatcher();


    final poolGameLevel = PoolGameLevel(allCompounds,
        swappableCompounds: swappableCompounds,
        displayedDifficulty: displayedDifficulty,
        maxShownComponentCount: maxShownComponentCount);

    poolGameLevel.shownComponents.clear();
    poolGameLevel.shownComponents.addAll(shownComponents);
    poolGameLevel.hiddenComponents.clear();
    poolGameLevel.hiddenComponents.addAll(hiddenComponents);
    poolGameLevel.hints.addAll(hints);
    poolGameLevel._unsolvedCompounds.clear();
    poolGameLevel._unsolvedCompounds.addAll(unsolvedCompounds);
    poolGameLevel.attemptsWatcher = attemptsWatcher;
    return poolGameLevel;
  }

  Map<String, dynamic> toJson() => {
    '_allCompounds': _allCompounds.map((compound) => compound.toJson()).toList(),
    '_unsolvedCompounds': _unsolvedCompounds.map((compound) => compound.toJson()).toList(),
    'swappableCompounds': swappableCompounds.map((compound) => compound.toJson()).toList(),
    'shownComponents': shownComponents.map((component) => component.toJson()).toList(),
    'hiddenComponents': hiddenComponents.map((component) => component.toJson()).toList(),
    'hints': hints.map((hint) => hint.toJson()).toList(),
    'displayedDifficulty': displayedDifficulty.index,
    'maxShownComponentCount': maxShownComponentCount,
    'attemptsWatcher': attemptsWatcher.toJson(),
  };
}
