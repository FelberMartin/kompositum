import 'dart:math';

import 'package:kompositum/config/locator.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/chain/generator/chain_generator.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';
import 'package:test/test.dart';

import '../../../../mocks/mock_database_interface.dart';
import '../../../../test_data/compounds.dart';

void main() {
  final databaseInterface = MockDatabaseInterface();
  late ChainGenerator sut;

  test("generation returns a chain if there is one", () async {
    databaseInterface.compounds = [
      Compounds.Apfelkuchen,
      Compounds.Kuchenform,
    ];
    sut = ChainGenerator(databaseInterface);
    final chain = await sut.generateRestricted(
      compoundCount: 2,
      frequencyClass: CompactFrequencyClass.easy,
    );
    expect(chain.getCompounds().length, 2);
  });

  test("generates both chains if there are two", () async {
    databaseInterface.compounds = [
      Compounds.Apfelkuchen,
      Compounds.Kuchenform,
      Compounds.Maschinenbau,
      Compounds.Bauamt,
    ];
    sut = ChainGenerator(databaseInterface);
    final chains = <ComponentChain>[];
    for (int i = 0; i < 10; i++) {
      final chain = await sut.generateRestricted(
        compoundCount: 2,
        frequencyClass: CompactFrequencyClass.easy,
      );
      chains.add(chain);
    }
    final distinctChains = chains.toSet();
    expect(distinctChains.length, 2);
    final ordered = distinctChains.toList()..sort((a, b) => a.toString().compareTo(b.toString()));
    expect(ordered[0].toString(), "Apfel Kuchen Form");
    expect(ordered[1].toString(), "Maschine Bau Amt");
  });

  test("conflicts: the chain is shorter if otherwise there would be conflicts", () async {
    databaseInterface.compounds = [
      Compounds.Apfelkuchen,
      Compounds.Kuchenform,
      Compounds.Formsache,
      // Artificial conflict "Kuchensache"
      // This is a conflict because, when "Kuchen" is the current modifier,
      // then both "Form" and "Sache" would be possible heads.
      Compound(id: 0, name: "Kuchensache", modifier: "Kuchen", head: "Sache", frequencyClass: 1),
    ];
    sut = ChainGenerator(databaseInterface);
    final chain = await sut.generateRestricted(
      compoundCount: 3,
      frequencyClass: CompactFrequencyClass.easy,
    );
    expect(chain.getCompounds().length, 2);
  });

  group("getBestChainForStartString", () {
    test("should return a chain with the start string", () async {
      databaseInterface.compounds = [
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
      ];
      sut = ChainGenerator(databaseInterface);
      final selectableCompounds = await databaseInterface
          .getCompoundsByCompactFrequencyClass(CompactFrequencyClass.easy);
      final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);

      final componentStrings = sut.getBestChainForStartString(
        startString: "apfel",
        selectableGraph: selectableGraph,
        conflictsGraph: selectableGraph.copy(),
        random: Random(0),
        maxChainLength: 3,
      );

      expect(componentStrings.length, 3);
      expect(componentStrings[0], "apfel");
    });
  });


  group("performance", skip: false, () {
    setUp(() {
      setupLocator();
    });

    test("measure time", () async {
      final databaseInterface = locator.get<DatabaseInterface>();
      sut = ChainGenerator(databaseInterface);
      final chainCount = 100;
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < chainCount; i++) {
        await sut.generateRestricted(
          compoundCount: 3,
          frequencyClass: CompactFrequencyClass.easy,
        );
      }

      final elapsed = stopwatch.elapsedMilliseconds;
      print("Elapsed: $elapsed ms");
    });
  });
}