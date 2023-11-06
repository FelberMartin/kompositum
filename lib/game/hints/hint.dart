import 'dart:math';

import '../../data/compound.dart';

enum HintComponentType { modifier, head }

class Hint {
  /// The component which this hint instance points to.
  final String hintedComponent;
  final HintComponentType type;

  Hint(this.hintedComponent, this.type);

  static Hint generate(List<Compound> compounds, List<String> shownComponents,
      List<Hint> previousHints) {
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
      List<Compound> compounds, List<String> shownComponents) {
    final possibleHintCompounds = compounds
        .where((compound) =>
            shownComponents.contains(compound.modifier) &&
            shownComponents.contains(compound.head))
        .toList();
    final random = Random();
    final hintedCompound =
        possibleHintCompounds[random.nextInt(possibleHintCompounds.length)];
    return Hint(hintedCompound.modifier, HintComponentType.modifier);
  }
}
