import 'dart:math';

import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';
import 'package:test/test.dart';

import '../../../test_data/compounds.dart';

void main() {
  group("fromCompounds", () {
    test("should create a graph from compounds", () {
      final compounds = Compounds.all;
      final allComponents = compounds
          .map((compound) => compound.getComponents())
          .expand((element) => element)
          .map((component) => component.toLowerCase())
          .toList();
      final compoundGraph = CompoundGraph.fromCompounds(compounds);
      expect(compoundGraph.getAllComponents(), allComponents.toSet().toList());
    });

    test("should create a graph from compounds with multiple modifiers", () {
      final compounds = [Compounds.Apfelbaum, Compounds.Apfelkuchen];
      final compoundGraph = CompoundGraph.fromCompounds(compounds);
      expect(compoundGraph.getAllComponents(), ["apfel", "baum", "kuchen"]);
    });
  });

  group("addCompound", () {
    test("should add a compound to the graph", () {
      final compoundGraph = CompoundGraph();
      compoundGraph.addCompound(Compounds.Apfelbaum);
      expect(compoundGraph.getAllComponents(), ["apfel", "baum"]);
    });

    test("should not add two links if the same compound is added twice", () {
      final compoundGraph = CompoundGraph();
      compoundGraph.addCompound(Compounds.Apfelbaum);
      compoundGraph.addCompound(Compounds.Apfelbaum);
      expect(compoundGraph.getAllComponents(), ["apfel", "baum"]);
      compoundGraph.removeCompound(Compounds.Apfelbaum);
      expect(compoundGraph.hasLink("apfel", "baum"), isFalse);
    });
  });

  group("removeCompound", () {
    test("should remove a compound from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum
      ]);
      compoundGraph.removeCompound(Compounds.Apfelbaum);
      final compound = compoundGraph.getRandomModifierHeadPair(Random());
      expect(compound, isNull);
    });
  });

  group("removeComponents", () {
    test("should remove all connected compounds from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen
      ]);
      compoundGraph.removeComponents(["Apfel"]);
      expect(compoundGraph.getAllComponents(), containsAll(["kuchen", "baum"]));
    });
  });

  group("getNeighbors", () {
    test("should return all neighbors of a component", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen, Compounds.Schneemann
      ]);
      expect(compoundGraph.getNeighbors("Apfel"), containsAll(["baum", "kuchen"]));
    });

    test("getLinkedModifiers should return all modifiers of a head", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen, Compounds.Schneemann
      ]);
      expect(compoundGraph.getLinkedModifiers("Baum"), contains("apfel"));
    });

    test("getLinkedHeads should return all heads of a modifier", ()
    {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen, Compounds.Schneemann
      ]);
      final result = compoundGraph.getLinkedHeads("Apfel");
      expect(result, contains("baum"));
      expect(result, contains("kuchen"));
    });
  });

  group("getConflictingComponents", () {
    test("should return the components of the given compound", () {
      final compoundGraph = CompoundGraph.fromCompounds([Compounds.Apfelbaum]);
      final conflicts = compoundGraph.getConflictingComponents(Compounds.Apfelbaum);
      expect(conflicts, isNotEmpty);
      expect(conflicts, containsAll(["apfel", "baum"]));
    });

    test("should remove conflicting compounds from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelkuchen, Compounds.Kuchenform, Compounds.Formsache,
        Compounds.SachSchaden, Compounds.Schneemann
      ]);
      final conflicts = compoundGraph.getConflictingComponents(Compounds.Apfelkuchen);
      expect(conflicts, containsAll(["apfel", "kuchen", "form"]));
      expect(conflicts, isNot(containsAll(["sache", "schaden", "schnee", "mann"])));
    });
  });

  group("getRandomModifierHeadPair", () {
    test("should return a pair if one exists", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum
      ]);
      final pair = compoundGraph.getRandomModifierHeadPair(Random());
      expect(pair, ("apfel", "baum"));
    });

    test("should return null if no components exist", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum
      ]);
      compoundGraph.removeComponents(["Apfel", "Baum"]);
      final pair = compoundGraph.getRandomModifierHeadPair(Random());
      expect(pair, isNull);
    });

    test("should return null if no linked components exist", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum
      ]);
      compoundGraph.removeComponents(["Apfel"]);
      final pair = compoundGraph.getRandomModifierHeadPair(Random());
      expect(pair, isNull);
    });

    test("should return different pairs on multiple calls", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen
      ]);
      final pairs = <(String, String)>[];
      for (var i = 0; i < 10; i++) {
        final pair = compoundGraph.getRandomModifierHeadPair(Random());
        pairs.add(pair!);
      }
      expect(pairs.toSet().length, 2);
    });

    test("should return the same pairs on multiple calls with the same seed", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen
      ]);
      final pairs = <(String, String)>[];
      for (var i = 0; i < 10; i++) {
        final pair = compoundGraph.getRandomModifierHeadPair(Random(1));
        pairs.add(pair!);
      }
      expect(pairs.toSet().length, 1);
    });

    test("should return a valid pair", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen, Compounds.Schneemann
      ]);
      compoundGraph.removeComponents(["Apfel"]);
      for (int i = 0; i < 5; i++) {
        final pair = compoundGraph.getRandomModifierHeadPair(Random());
        expect(pair, ("schnee", "mann"));
      }
    });
  });

  group("graph is now case insensitive", () {
    test("should add only one component if the same component is added twice, once uppercased and once lowercased", () {
      final compoundGraph = CompoundGraph();
      compoundGraph.addCompound(Compound(id: 0, name: "Apfelbaum", modifier: "Apfel", head: "Baum"));
      compoundGraph.addCompound(Compound(id: 0, name: "apfelbaum", modifier: "apfel", head: "baum"));
      expect(compoundGraph.getAllComponents(), ["apfel", "baum"]);
    });
  });

  group("copy", () {
    test("should create a copy of the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen, Compounds.Schneemann
      ]);
      final copy = compoundGraph.copy();
      expect(copy.getAllComponents(), compoundGraph.getAllComponents());
      expect(copy.getNeighbors("apfel"), compoundGraph.getNeighbors("apfel"));
    });
  });
}