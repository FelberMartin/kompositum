import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/game_level.dart';
import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';

import '../../../data/models/compound.dart';



class ChainGameLevel extends GameLevel {

  @override
  final maxHintCount = 1;

  late UniqueComponent currentModifier;

  ChainGameLevel(
    ComponentChain componentChain,
    {
      super.maxShownComponentCount = 9,
  }) : super(
    swappableCompounds: const [],   // No swappables for chain mode, they would mess up the chain order.
  ) {
    final components = componentChain.components;
    currentModifier = components.first;
    components.removeAt(0);
    super.initialize(
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

  @override
  Hint generateHint() {
    final dummyHint = Hint(currentModifier, HintComponentType.modifier);
    return Hint.generate(allCompounds, shownComponents, [dummyHint]);
  }

}
