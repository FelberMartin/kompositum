import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/modi/chain/chain_game_level.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:test/test.dart';

import '../../../test_data/compounds.dart';
import '../../game_level_test.dart';

void main() {
  late ChainGameLevel sut;

  ComponentChain createChain(List<Compound> compounds) {
    final components = <UniqueComponent>[];
    for (var compound in compounds) {
      components.add(UniqueComponent(compound.modifier));
    }
    components.add(UniqueComponent(compounds.last.head));
    return ComponentChain(components, compounds);
  }

  group("Hints", () {
    setUp(() {
      sut = ChainGameLevel(createChain([Compounds.Apfelbaum]));
    });

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

  test("shownComponents: should be the length of maxShownComponentCount", () {
    sut = ChainGameLevel(createChain([Compounds.Apfelbaum, Compounds.Schneemann]), maxShownComponentCount: 2);
    expect(sut.shownComponents.length, 2);
    expect(sut.shownComponents, isNot(contains(sut.currentModifier)));
  });

  group("getNextShownComponent", () {
    test("should return the continuation of the chain", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache,
        Compounds.SachSchaden,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 2);
      sut.currentModifier = chain.components[0];
      initShownAndHiddenComponents(sut, ["Form"]);

      for (var i = 0; i < 5; i++) {
        // Repeat to ensure that the test is not passing by luck
        final nextComponent = sut.getNextShownComponent();
        expect(nextComponent.text, "Kuchen");
      }
    });

    test("minSolvableCompoundsInPool: should add the next two chain elements if set to two", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache,
        Compounds.SachSchaden,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 2, minSolvableCompoundsInPool: 2);
      sut.currentModifier = chain.components[0];
      initShownAndHiddenComponents(sut, []);

      for (var i = 0; i < 5; i++) {
        // Repeat to ensure that the test is not passing by luck
        final nextComponent = sut.getNextShownComponent();
        expect(nextComponent.text, "Kuchen");

        sut.shownComponents.add(nextComponent);
        final nextComponent2 = sut.getNextShownComponent();
        expect(nextComponent2.text, "Form");

        // Undo
        sut.shownComponents.removeLast();
      }
    });

    test("should also work with bigger pool sizes", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache,
        Compounds.SachSchaden,
        Compounds.Schadensbegrenzung,
        Compounds.Begrenzungslinie,
        Compounds.Linienrichter,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 4, minSolvableCompoundsInPool: 2);
      sut.currentModifier = chain.components[0];
      initShownAndHiddenComponents(sut, ["Kuchen", "Sache", "Schaden", "Begrenzung"]);

      for (var i = 0; i < 5; i++) {
        // Repeat to ensure that the test is not passing by luck
        final nextComponent = sut.getNextShownComponent();
        expect(nextComponent.text, "Form");
      }
    });
  });

  group("countNextSolvableCompoundsInPool", () {
    test("should return 1 if one chain step can be solved", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 1);
      sut.currentModifier = chain.components[0];    // Apfel
      initShownAndHiddenComponents(sut, ["Kuchen"]);

      final result = sut.countNextSolvableCompoundsInPool();
      expect(result, 1);
    });

    test("should return 2 if two consecutive chain steps can be solved", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 2);
      sut.currentModifier = chain.components[0];    // Apfel
      initShownAndHiddenComponents(sut, ["Kuchen", "Form"]);

      expect(sut.countNextSolvableCompoundsInPool(), 2);
    });

    test("should return 0 if no consecutive chain steps can be solved", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 2);
      sut.currentModifier = chain.components[0];    // Apfel
      initShownAndHiddenComponents(sut, ["Form", "Sache"]);

      expect(sut.countNextSolvableCompoundsInPool(), 0);
    });

    test("should return 1 if one chain step is missing", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache,
        Compounds.SachSchaden,
        Compounds.Schadensbegrenzung,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 3);
      sut.currentModifier = chain.components[0];    // Apfel
      initShownAndHiddenComponents(sut, ["Kuchen", "Sache", "Schaden"]);    // Missing: "Form"

      expect(sut.countNextSolvableCompoundsInPool(), 1);
    });
  });

  group("removeCompoundFromShown", () {
    test("removes the head and sets it as the new currentModifier", () {
      final chain = createChain([
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache,
        Compounds.SachSchaden,
      ]);
      sut = ChainGameLevel(chain, maxShownComponentCount: 2);
      sut.currentModifier = chain.components[0];
      initShownAndHiddenComponents(sut, ["Kuchen"]);

      sut.removeCompoundFromShown(Compounds.Apfelkuchen, chain.components[0], chain.components[1]);
      expect(sut.currentModifier.text, "Kuchen");
      expect(sut.shownComponents, isNotEmpty);
      expect(sut.shownComponents, isNot(contains(chain.components[0])));
    });
  });
}