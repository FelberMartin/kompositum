import 'dart:math';

import 'package:kompositum/game/pool_game_level.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically

import '../../data/models/compound.dart';
import '../../data/models/unique_component.dart';

enum HintComponentType { modifier, head }

class Hint {
  /// The component which this hint instance points to.
  final String hintedComponent;
  final HintComponentType type;

  Hint(this.hintedComponent, this.type);

  static Hint generate(List<Compound> compounds,
      List<UniqueComponent> shownComponents, List<Hint> previousHints) {
    if (previousHints.length == 2) {
      throw Exception('There are already two hints: $previousHints');
    }

    if (previousHints.length == 1) {
      return _generateHintForHead(compounds, previousHints.first);
    }

    return _generateHintForModifier(compounds, shownComponents);
  }

  static Hint _generateHintForHead(
      List<Compound> compounds, Hint previousHint) {
    assert(previousHint.type == HintComponentType.modifier);

    final hintedCompound = compounds.firstWhere(
        (compound) => compound.modifier == previousHint.hintedComponent);
    return Hint(hintedCompound.head, HintComponentType.head);
  }

  static Hint _generateHintForModifier(
      List<Compound> compounds, List<UniqueComponent> shownComponents) {
    final possibleHintCompounds = compounds
        .where((compound) => compound.isSolvedBy(shownComponents))
        .toList();

    if (possibleHintCompounds.isEmpty) {
      throw Exception(
          'There is no possible hint for the given compounds: $compounds');
    }

    final random = Random();
    final hintedCompound =
        possibleHintCompounds[random.nextInt(possibleHintCompounds.length)];
    return Hint(hintedCompound.modifier, HintComponentType.modifier);
  }
}
