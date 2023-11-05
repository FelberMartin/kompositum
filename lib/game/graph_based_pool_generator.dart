import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:graph_collection/graph.dart';
import 'package:kompositum/game/compound_pool_generator.dart';

import '../data/compound.dart';
import 'compound_graph.dart';

class GraphBasedPoolGenerator extends CompoundPoolGenerator {

  late final Future<CompoundGraph> _fullGraph;

  GraphBasedPoolGenerator(super.databaseInterface) {
    _fullGraph = _getFullGraph();
  }

  Future<CompoundGraph> _getFullGraph() async {
    return CompoundGraph.fromCompounds(await databaseInterface.getAllCompounds());
  }

  @override
  Future<List<Compound>> generateWithoutValidation(int compoundCount,
      CompactFrequencyClass frequencyClass, int? seed) async {
    final stopWatch = Stopwatch()..start();
    final fullGraph = await _fullGraph;

    var selectableCompounds = await databaseInterface.getCompoundsByCompactFrequencyClass(frequencyClass);
    final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);

    final compounds = <Compound>[];
    final random = seed == null ? Random() : Random(seed);
    for (int i = 0; i < compoundCount; i++) {
      // print("Selectable compounds: ${selectableGraph.getAllComponents().length}");
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

    debugPrint("Graph based pool generation took ${stopWatch.elapsedMilliseconds} ms");
    return compounds;
  }
}
