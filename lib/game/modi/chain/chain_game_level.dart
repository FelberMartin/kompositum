import 'dart:math';

import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';

import '../../../data/models/compound.dart';



class ChainGameLevel extends GameLevel {

  @override
  final maxHintCount = 1;

  final ComponentChain componentChain;
  late UniqueComponent currentModifier;

  ChainGameLevel(
    this.componentChain,
    {
      super.maxShownComponentCount = 9,
      super.minSolvableCompoundsInPool = 1,
  }) : super(
    swappableCompounds: const [],   // No swappables for chain mode, they would mess up the chain order.
  ) {
    final componentsCopy = componentChain.components.toList();
    currentModifier = componentsCopy.first;
    componentsCopy.removeAt(0);
    super.initialize(
      compounds: componentChain.compounds,
      selectableComponents: componentsCopy,
    );
  }

  @override
  void removeCompoundFromShown(
      Compound compound,
      UniqueComponent modifier,
      UniqueComponent head,
  ) {
    currentModifier = head;
    super.removeCompoundFromShown(compound, modifier, head);
  }

  @override
  Hint generateHint() {
    final dummyHint = Hint(currentModifier, HintComponentType.modifier);
    return Hint.generate(allCompounds, shownComponents, [dummyHint]);
  }

  @override
  UniqueComponent findComponentToCreateNewSolvable(Random random) {
    return _findNextHiddenComponentInChain(currentModifier);
  }

  UniqueComponent _findNextHiddenComponentInChain(UniqueComponent modifier) {
    final nextComponent = _findNextComponentInChain(modifier);
    if (!shownComponents.contains(nextComponent)) {
      return nextComponent;
    }
    return _findNextHiddenComponentInChain(nextComponent);
  }

  UniqueComponent _findNextComponentInChain(UniqueComponent modifier) {
    final modifierIndex = componentChain.components.indexOf(modifier);
    if (modifierIndex == -1) {
      throw Exception("Current modifier not found in chain.");
    }
    if (modifierIndex == componentChain.components.length - 1) {
      throw Exception("The end of the chain has been reached.");
    }
    return componentChain.components[modifierIndex + 1];
  }


}
