import 'dart:math';

import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/difficulty.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/swappable_detector.dart';

import '../../../config/star_costs_rewards.dart';
import '../../../data/models/compound.dart';
import '../../attempts_watcher.dart';
import '../../hints/hint.dart';
import '../pool/pool_game_level.dart';
import 'generator/chain_generator.dart';



class ChainGameLevel extends GameLevel {

  late UniqueComponent currentModifier;

  ChainGameLevel(
    ComponentChain componentChain,
    {
      super.maxShownComponentCount = 9,
      super.swappableCompounds = const [],
  }) {
    final components = componentChain.components;
    currentModifier = components.first;
    components.removeAt(0);
    super.setup(
      compounds: componentChain.compounds,
      selectableComponents: components,
    );
  }

  @override
  void removeCompoundFromShown(
      Compound compound,
      UniqueComponent modifier,
      UniqueComponent head,
  ) {
    super.removeCompoundFromShown(compound, modifier, head);
    currentModifier = head;
  }

}
