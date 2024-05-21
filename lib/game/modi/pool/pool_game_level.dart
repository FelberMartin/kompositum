import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/swappable_detector.dart';

import '../../../config/star_costs_rewards.dart';
import '../../../data/models/compound.dart';
import '../../attempts_watcher.dart';
import '../../hints/hint.dart';



class PoolGameLevel extends GameLevel {

  PoolGameLevel(
    List<Compound> allCompounds,
    {
      super.maxShownComponentCount = 11,
      super.displayedDifficulty = Difficulty.easy,
      super.swappableCompounds = const [],
  }) {
    super.setup(
      compounds: allCompounds,
      selectableComponents: UniqueComponent.fromCompounds(allCompounds),
    );
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


    final poolGameLevel = PoolGameLevel(
      allCompounds,
      swappableCompounds: swappableCompounds,
      displayedDifficulty: displayedDifficulty,
      maxShownComponentCount: maxShownComponentCount
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
    'displayedDifficulty': displayedDifficulty.index,
    'maxShownComponentCount': maxShownComponentCount,
    'attemptsWatcher': attemptsWatcher.toJson(),
  };
}
