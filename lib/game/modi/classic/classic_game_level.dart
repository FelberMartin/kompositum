import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/difficulty.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/modi/classic/generator/classic_level_content.dart';
import 'package:kompositum/game/swappable_detector.dart';

import '../../../config/star_costs_rewards.dart';
import '../../../data/models/compound.dart';
import '../../attempts_watcher.dart';
import '../../hints/hint.dart';



class ClassicGameLevel extends GameLevel {

  ClassicGameLevel(
    ClassicLevelContent levelContent,
    {
      super.maxShownComponentCount = 9,
      super.minSolvableCompoundsInPool = 1,
      super.swappableCompounds = const [],
  }) {
    super.initialize(
      compounds: levelContent.getCompounds(),
      selectableComponents: levelContent.selectableComponents(),
    );
  }

  @override
  int countNextSolvableCompoundsInPool() {
    return allCompounds
        .where((compound) => compound.isSolvedBy(shownComponents)).length;
  }

  @override
  UniqueComponent findComponentToCreateNewSolvable(Random random) {
    final compoundsCurrentlyCompletable = unsolvedCompounds
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

  @override
  Hint generateHint() {
    return Hint.generate(allCompounds, shownComponents, hints);
  }

  static ClassicGameLevel fromJson(Map<String, dynamic> json) {
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
    final maxShownComponentCount = json['maxShownComponentCount'] as int;
    final attemptsWatcher = json.containsKey('attemptsWatcher') ? AttemptsWatcher.fromJson(json['attemptsWatcher']) : AttemptsWatcher();


    final poolGameLevel = ClassicGameLevel(
      ClassicLevelContent(allCompounds),
      swappableCompounds: swappableCompounds,
      maxShownComponentCount: maxShownComponentCount,
    );

    poolGameLevel.shownComponents.clear();
    poolGameLevel.shownComponents.addAll(shownComponents);
    poolGameLevel.hiddenComponents.clear();
    poolGameLevel.hiddenComponents.addAll(hiddenComponents);
    poolGameLevel.hints.addAll(hints);
    poolGameLevel.unsolvedCompounds.clear();
    poolGameLevel.unsolvedCompounds.addAll(unsolvedCompounds);
    poolGameLevel.attemptsWatcher = attemptsWatcher;
    return poolGameLevel;
  }

  Map<String, dynamic> toJson() => {
    '_allCompounds': allCompounds.map((compound) => compound.toJson()).toList(),
    '_unsolvedCompounds': unsolvedCompounds.map((compound) => compound.toJson()).toList(),
    'swappableCompounds': swappableCompounds.map((compound) => compound.toJson()).toList(),
    'shownComponents': shownComponents.map((component) => component.toJson()).toList(),
    'hiddenComponents': hiddenComponents.map((component) => component.toJson()).toList(),
    'hints': hints.map((hint) => hint.toJson()).toList(),
    'maxShownComponentCount': maxShownComponentCount,
    'attemptsWatcher': attemptsWatcher.toJson(),
  };
}
