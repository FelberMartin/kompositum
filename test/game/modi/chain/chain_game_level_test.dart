import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/modi/chain/chain_game_level.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:test/test.dart';

import '../../../data/models/compound_test.dart';
import '../../../test_data/compounds.dart';

void main() {
  late ChainGameLevel sut;

  ChainGameLevel createSut(List<Compound> compounds) {
    final components = UniqueComponent.fromCompounds(compounds);
    return ChainGameLevel(ComponentChain(components, compounds));
  }

  setUp(() {
    sut = createSut([Compounds.Apfelbaum]);
  });

  group("Hints", () {
    test("should return a hint for the currentModifier", () {
      sut.requestHint(999);
      expect(sut.hints.length, 1);
      final hint = sut.hints.first;
      expect(sut.currentModifier.text, equals("Apfel"));
      expect(hint.type, HintComponentType.head);
      expect(hint.hintedComponent.text, equals("Baum"));
    });

    test("should do nothing if a second hint is requested", () {
      sut.requestHint(999);
      sut.requestHint(999);
      expect(sut.hints.length, 1);
    });
  });
}