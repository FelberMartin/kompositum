import 'dart:math';

import '../../data/models/compound.dart';
import '../../data/models/unique_component.dart';

enum HintComponentType { modifier, head }

class Hint {
  /// The component which this hint instance points to.
  final UniqueComponent hintedComponent;
  final HintComponentType type;

  Hint(this.hintedComponent, this.type);

  static Hint generate(List<Compound> compounds,
      List<UniqueComponent> shownComponents, List<Hint> previousHints) {
    if (previousHints.length == 2) {
      throw Exception('There are already two hints: $previousHints');
    }

    if (previousHints.length == 1) {
      return _generateHintForHead(compounds, shownComponents, previousHints.first);
    }

    return _generateHintForModifier(compounds, shownComponents);
  }

  static Hint _generateHintForHead(
      List<Compound> compounds, List<UniqueComponent> shownComponents, Hint previousHint) {
    assert(previousHint.type == HintComponentType.modifier);

    final hintedCompound = compounds.firstWhere(
        (compound) => compound.modifier == previousHint.hintedComponent.text);
    final hintedComponent = shownComponents.firstWhere(
        (component) => component.text == hintedCompound.head);
    return Hint(hintedComponent, HintComponentType.head);
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
    final hintedComponent = shownComponents.firstWhere(
        (component) => component.text == hintedCompound.modifier);
    return Hint(hintedComponent, HintComponentType.modifier);
  }

  Hint.fromJson(Map<String, dynamic> json) :
    hintedComponent = UniqueComponent.fromJson(json['hintedComponent']),
    type = json['type'] == 'modifier' ? HintComponentType.modifier : HintComponentType.head;

  Map<String, dynamic> toJson() => {
    'hintedComponent': hintedComponent.toJson(),
    'type': type == HintComponentType.modifier ? 'modifier' : 'head',
  };

  @override
  String toString() {
    return 'Hint{hintedComponent: $hintedComponent, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hint &&
          runtimeType == other.runtimeType &&
          hintedComponent == other.hintedComponent &&
          type == other.type;

  @override
  int get hashCode => hintedComponent.hashCode ^ type.hashCode;
}
