import 'package:kompositum/game/hints/hint.dart';
import 'package:test/test.dart';

import '../../test_data/compounds.dart';

void main() {
  group('generateHint', () {
    test('should return a hint for the shown compound', () {
      final compounds = [Compounds.Apfelbaum];
      final hint = Hint.generate(compounds, ['Apfel', 'Baum'], []);
      expect(hint.hintedComponent, equals('Apfel'));
      expect(hint.type, equals(HintComponentType.modifier));
    });

    test('should return a hint for the head if there is already a hint for the modifier', () {
      final compounds = Compounds.all;
      final previousHint = Hint('Apfel', HintComponentType.modifier);
      final hint = Hint.generate(compounds, ['Apfel', 'Baum'], [previousHint]);
      expect(hint.hintedComponent, equals('Baum'));
      expect(hint.type, equals(HintComponentType.head));
    });

    test("should return different modifier hint for multiple calls", () {
      final compounds = [Compounds.Apfelbaum, Compounds.Schneemann];
      final hintedComponents = [];
      for (var i = 0; i < 10; i++) {
        final hint = Hint.generate(compounds, ["Apfel", "Baum", "Schnee", "Mann"], []);
        hintedComponents.add(hint.hintedComponent);
      }
      expect(hintedComponents.toSet().length, 2);
    });

    test("should throw an expection if there are already two hints", () {
      final compounds = [Compounds.Apfelbaum, Compounds.Apfelkuchen];
      final previousHints = [Hint('Apfel', HintComponentType.modifier), Hint('Baum', HintComponentType.head)];
      expect(() => Hint.generate(compounds, ["Apfel", "Baum", "Kuchen"], previousHints), throwsException);
    });
  });
}