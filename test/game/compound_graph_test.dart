import 'package:kompositum/game/compound_graph.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

void main() {
  group("fromCompounds", () {
    test("should create a graph from compounds", () {
      final compounds = Compounds.all;
      final compoundGraph = CompoundGraph.fromCompounds(compounds);
      expect(compoundGraph.getCompounds(), compounds);
    });

    test("should create a graph from compounds with multiple modifiers", () {
      final compounds = [Compounds.Apfelbaum, Compounds.Apfelkuchen];
      final compoundGraph = CompoundGraph.fromCompounds(compounds);
      expect(compoundGraph.getCompounds(), compounds);
    });
  });

  group("addCompound", () {
    test("should add a compound to the graph", () {
      final compoundGraph = CompoundGraph();
      compoundGraph.addCompound(Compounds.Apfelbaum);
      expect(compoundGraph.getCompounds(), [Compounds.Apfelbaum]);
    });
  });

  group("getCompound", () {
    test("should return a compound if it exists", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen
      ]);
      final compound = compoundGraph.getCompound("Apfel", "Baum");
      expect(compound, Compounds.Apfelbaum);
    });

    test("should return null if the compound does not exist", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen
      ]);
      final compound = compoundGraph.getCompound("Pflaume", "Baum");
      expect(compound, isNull);
    });
  });

  group("removeCompound", () {
    test("should remove a compound from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds(Compounds.all);
      compoundGraph.removeCompound(Compounds.Apfelbaum);
      expect(compoundGraph.getCompounds(), isNot(contains(Compounds.Apfelbaum)));
    });

    test("should not remove a compound from the graph if it does not exist", () {
      final compoundGraph = CompoundGraph.fromCompounds([Compounds.Schneemann]);
      compoundGraph.removeCompound(Compounds.Apfelbaum);
      expect(compoundGraph.getCompounds(), [Compounds.Schneemann]);
    });
  });

  group("removeComponent", () {
    test("should remove all connected compounds from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen
      ]);
      compoundGraph.removeComponent("Apfel");
      expect(compoundGraph.getCompounds(), isEmpty);
    });

    test("should remove all connected compounds from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen, Compounds.Kuchenform,
        Compounds.Adamsapfel
      ]);
      compoundGraph.removeComponent("Apfel");
      expect(compoundGraph.getCompounds(), isNot(contains(Compounds.Apfelbaum)));
      expect(compoundGraph.getCompounds(), isNot(contains(Compounds.Apfelkuchen)));
      expect(compoundGraph.getCompounds(), contains(Compounds.Kuchenform));

    });
  });

  group("removeCompoundAndConflicts", () {
    test("should remove a compound from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds(Compounds.all);
      compoundGraph.removeCompoundAndConflicts(Compounds.Apfelbaum);
      expect(compoundGraph.getCompounds(), isNot(contains(Compounds.Apfelbaum)));
    });

    test("should remove compounds with overlapping components from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelbaum, Compounds.Apfelkuchen
      ]);
      compoundGraph.removeCompoundAndConflicts(Compounds.Apfelbaum);
      expect(compoundGraph.getCompounds(), isEmpty);
    });

    test("should remove conflicting compounds from the graph", () {
      final compoundGraph = CompoundGraph.fromCompounds([
        Compounds.Apfelkuchen, Compounds.Kuchenform, Compounds.Formsache,
        Compounds.SachSchaden, Compounds.Schneemann
      ]);
      compoundGraph.removeCompoundAndConflicts(Compounds.Apfelkuchen);
      expect(compoundGraph.getCompounds(), isNot(contains(Compounds.Apfelkuchen)));
      expect(compoundGraph.getCompounds(), isNot(contains(Compounds.Kuchenform)));
      expect(compoundGraph.getCompounds(), isNot(contains(Compounds.Formsache)));
      expect(compoundGraph.getCompounds(), contains(Compounds.SachSchaden));
      expect(compoundGraph.getCompounds(), contains(Compounds.Schneemann));
    });
  });
}