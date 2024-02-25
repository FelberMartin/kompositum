import 'package:kompositum/game/hints/hint.dart';
import 'package:test/test.dart';

import '../../data/models/compound_test.dart';
import '../../test_data/compounds.dart';


void main() {
  group('generateHint', () {
    test('should return a hint for the shown compound', () {
      final compounds = [Compounds.Apfelbaum];
      final components = getUniqueComponents(['Apfel', 'Baum']);
      final hint = Hint.generate(compounds, components, []);
      expect(hint.hintedComponent.text, equals('Apfel'));
      expect(hint.type, equals(HintComponentType.modifier));
    });

    test('should return a hint for the head if there is already a hint for the modifier', () {
      final compounds = Compounds.all;
      final components = getUniqueComponents(['Apfel', 'Baum']);
      final previousHint = Hint(components[0], HintComponentType.modifier);
      final hint = Hint.generate(compounds, components, [previousHint]);
      expect(hint.hintedComponent.text, equals('Baum'));
      expect(hint.type, equals(HintComponentType.head));
    });

    test("should return different modifier hint for multiple calls", () {
      final compounds = [Compounds.Apfelbaum, Compounds.Schneemann];
      final components = getUniqueComponents(['Apfel', 'Baum', 'Schnee', 'Mann']);
      final hintedComponents = [];
      for (var i = 0; i < 10; i++) {
        final hint = Hint.generate(compounds, components, []);
        hintedComponents.add(hint.hintedComponent);
      }
      expect(hintedComponents.toSet().length, 2);
    });

    test("should throw an expection if there are already two hints", () {
      final compounds = [Compounds.Apfelbaum, Compounds.Apfelkuchen];
      final components = getUniqueComponents(['Apfel', 'Baum', 'Kuchen']);
      final previousHints = [Hint(components[0], HintComponentType.modifier), Hint(components[1], HintComponentType.head)];
      expect(() => Hint.generate(compounds, components, previousHints), throwsException);
    });

    test("edgecase Kindeskind: should throw an exception if it is not possible", () {
      final compounds = [Compounds.Kindeskind];
      final components = getUniqueComponents(['Kind']);
      expect(() => Hint.generate(compounds, components, []), throwsException);
    });
  });
}