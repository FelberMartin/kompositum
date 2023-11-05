import 'package:kompositum/data/compound.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:test/test.dart';

void main() {
  group("fromMap", () {
      test(
        "should return a compound with the given values",
        () {
          final map = {
            "name": "Krankenhaus",
            "modifier": "krank",
            "head": "Haus",
            "frequencyClass": 1,
          };
          final compound = Compound.fromMap(map);
          expect(compound.name, "Krankenhaus");
          expect(compound.modifier, "krank");
          expect(compound.head, "Haus");
          expect(compound.frequencyClass, 1);
        },
      );

      test(
        "should return a compound with null as frequency class if the frequency class is not given",
        () {
          final map = {
            "name": "Krankenhaus",
            "modifier": "krank",
            "head": "Haus",
            "frequency_class": null,
          };
          final compound = Compound.fromMap(map);
          expect(compound.name, "Krankenhaus");
          expect(compound.modifier, "krank");
          expect(compound.head, "Haus");
          expect(compound.frequencyClass, null);
        },
      );
    });

  test(
    "toMap and fromMap work together correctly",
    () {
      const compound = Compound(
        name: "Krankenhaus",
        modifier: "krank",
        head: "Haus",
        frequencyClass: 1,
      );
      final map = compound.toMap();
      final compoundFromMap = Compound.fromMap(map);
      expect(compound, compoundFromMap);
    },
  );

  test(
    "withFrequencyClass works as expected",
    () {
      const compound = Compound(
        name: "Krankenhaus",
        modifier: "krank",
        head: "Haus",
        frequencyClass: 1,
      );
      final compoundWithFrequencyClass = compound.withFrequencyClass(2);
      expect(compoundWithFrequencyClass.frequencyClass, 2);
    },
  );

  test(
    "withCompactFrequencyClass works as expected",
    () {
      const compound = Compound(
        name: "Krankenhaus",
        modifier: "krank",
        head: "Haus",
        frequencyClass: 1,
      );
      final compoundWithFrequencyClass = compound.withCompactFrequencyClass(CompactFrequencyClass.easy);
      expect(compoundWithFrequencyClass.frequencyClass, lessThanOrEqualTo(CompactFrequencyClass.easy.maxFrequencyClass!));
    });
}
