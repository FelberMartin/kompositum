import 'dart:math';

import 'package:graph_collection/graph.dart';
import 'package:kompositum/game/compound_pool_generator.dart';

import '../data/compound.dart';
import 'compound_graph.dart';

class GraphBasedPoolGenerator extends CompoundPoolGenerator {
  GraphBasedPoolGenerator(super.databaseInterface);

  @override
  Future<List<Compound>> generateWithoutValidation(int compoundCount,
      CompactFrequencyClass frequencyClass, int? seed) async {
    final allCompounds = await databaseInterface.getCompoundsByFrequencyClass(null);
    final stopWatch = Stopwatch()..start();
    final fullGraph = CompoundGraph.fromCompounds(allCompounds);
    print("Graph creation took ${stopWatch.elapsedMilliseconds} ms\n");

    var selectableCompounds = await databaseInterface.getCompoundsByCompactFrequencyClass(frequencyClass);
    final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);

    final compounds = <Compound>[];
    final random = seed == null ? Random() : Random(seed);
    for (int i = 0; i < compoundCount; i++) {
      print("Selecatble compounds: ${selectableGraph.getAllComponents().length}");
      final pair = selectableGraph.getRandomModifierHeadPair(random);
      if (pair == null) {
        break;
      }
      final compound = await databaseInterface.getCompound(pair.$1, pair.$2);
      if (compound == null) {
        throw Exception("Compound not found: ${pair.$1}+${pair.$2}");
      }
      compounds.add(compound);
      final conflicts = fullGraph.getConflictingComponents(compound);
      selectableGraph.removeComponents(conflicts);
    }

    return compounds;
  }
}
