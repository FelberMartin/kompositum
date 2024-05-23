import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/chain/generator/chain_generator.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../../../../config/test_locator.dart';
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
    setUp(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await setupTestLocator();
    });

    test("measure time for many chain creations", () async {
      final databaseInterface = locator.get<DatabaseInterface>();
      sut = ChainGenerator(databaseInterface);
      final chainCount = 100;
      final compoundCound = 15;
      final stopwatch = Stopwatch();
      final stopwatchTimes = <int>[];
      final chains = <ComponentChain>[];
      for (int i = 0; i < chainCount; i++) {
        stopwatch.reset();
        stopwatch.start();
        final chain = await sut.generateRestricted(
          compoundCount: compoundCound,
          frequencyClass: CompactFrequencyClass.medium,
          seed: i,
        );
        chains.add(chain);
        stopwatch.stop();
        stopwatchTimes.add(stopwatch.elapsedMilliseconds);
      }

      print("\n#############################################################");


      // Print the average length of the chains and how often the expected length was reached
      final expectedLength = compoundCound + 1;
      final averageLength = chains.map((chain) => chain.getCompounds().length).reduce((a, b) => a + b) / chainCount;
      final expectedLengthCount = chains.where((chain) => chain.getCompounds().length == expectedLength).length;
      print("Average length: $averageLength, expected length ($expectedLength) reached $expectedLengthCount/$chainCount");

      // Print the average, min and max time
      final average = stopwatchTimes.reduce((a, b) => a + b) / chainCount;
      final minT = stopwatchTimes.reduce(min);
      final maxT = stopwatchTimes.reduce(max);
      print("Average: $average ms, min: $minT ms, max: $maxT ms");

      /* Write down the improvements here:

      Recursive implementation:
        Average length: 6.81, expected length (16) reached 0/100
        Average: 407.85 ms, min: 300 ms, max: 1769 ms

      Increase maxIterations to 50:
        Average length: 6.81, expected length (16) reached 0/100
        Average: 418.4 ms, min: 317 ms, max: 1755 ms

      Initial implementation:
        Average length: 4.58, expected length (16) reached 0/100
        Average: 144.21 ms, min: 93 ms, max: 1435 ms
       */
    });
  });
}