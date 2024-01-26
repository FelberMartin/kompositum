import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:test/test.dart';

import '../../test_data/compounds.dart';


List<UniqueComponent> getUniqueComponents(List<String> strings) {
  final uniqueComponents = <UniqueComponent>[];
  var id = 0;
  for (final string in strings) {
    uniqueComponents.add(UniqueComponent(string, id++));
  }
  return uniqueComponents;
}

void main() {
  group("fromMap", () {
      test(
        "should return a compound with the given values",
        () {
          final map = {
            "id": 0,
            "name": "Krankenhaus",
            "modifier": "krank",
            "head": "Haus",
            "frequencyClass": 1,
          };
          final compound = Compound.fromJson(map);
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
            "id": 0,
            "name": "Krankenhaus",
            "modifier": "krank",
            "head": "Haus",
            "frequency_class": null,
          };
          final compound = Compound.fromJson(map);
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
      var compound = Compound(
        id: 0,
        name: "Krankenhaus",
        modifier: "krank",
        head: "Haus",
        frequencyClass: 1,
      );
      final map = compound.toJson();
      final compoundFromMap = Compound.fromJson(map);
      expect(compound, compoundFromMap);
    },
  );

  test(
    "withFrequencyClass works as expected",
    () {
      var compound = Compound(
        id: 0,
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
      var compound = Compound(
        id: 0,
        name: "Krankenhaus",
        modifier: "krank",
        head: "Haus",
        frequencyClass: 1,
      );
      final compoundWithFrequencyClass = compound.withCompactFrequencyClass(CompactFrequencyClass.easy);
      expect(compoundWithFrequencyClass.frequencyClass, lessThanOrEqualTo(CompactFrequencyClass.easy.maxFrequencyClass!));
    });

  group("isSolvedBy", () {
    test("should return false if the compound is not solved by the given components", () {
      var compound = Compounds.Schneemann;
      final components = getUniqueComponents(["krank", "Haus"]);
      expect(compound.isSolvedBy(components), false);
    });

    test("should return true if the compound is solved by the given components", () {
      var compound = Compounds.Schneemann;
      final components = getUniqueComponents(["Schnee", "Mann"]);
      expect(compound.isSolvedBy(components), true);
    });

    test("should return true if the compound is solved by the given components in a different order", () {
      var compound = Compounds.Schneemann;
      final components = getUniqueComponents(["Mann", "Schnee"]);
      expect(compound.isSolvedBy(components), true);
    });

    test("should return false if only one component is given", () {
      var compound = Compounds.Schneemann;
      final components = getUniqueComponents(["Mann"]);
      expect(compound.isSolvedBy(components), false);
    });

    test("should return false in edgecase Kindeskind", () {
      var compound = Compounds.Kindeskind;
      final components = getUniqueComponents(["Kind"]);
      expect(compound.isSolvedBy(components), false);
    });

    test("should return true in edgecase Kindeskind", ()
    {
      var compound = Compounds.Kindeskind;
      final components = getUniqueComponents(["Kind", "Kind"]);
      expect(compound.isSolvedBy(components), true);
    });
  });

  group("isOnlyPartialySolvedBy", () {
    test("should return false if the compound is not at all solved by the given components", () {
      var compound = Compounds.Schneemann;
      final components = getUniqueComponents(["krank", "Haus"]);
      expect(compound.isOnlyPartiallySolvedBy(components), false);
    });

    test("should return false if the compound is solved by the given components", () {
      var compound = Compounds.Schneemann;
      final components = getUniqueComponents(["Schnee", "Mann"]);
      expect(compound.isOnlyPartiallySolvedBy(components), false);
    });

    test("should return true if the compound is only partially solved by the given components", () {
      var compound = Compounds.Schneemann;
      final components = getUniqueComponents(["Schnee", "Apfel"]);
      expect(compound.isOnlyPartiallySolvedBy(components), true);
    });

    test("should return true for edgecase Kindeskind", () {
      var compound = Compounds.Kindeskind;
      final components = getUniqueComponents(["Kind"]);
      expect(compound.isOnlyPartiallySolvedBy(components), true);
    });
  });
}
