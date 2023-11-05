import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:graph_collection/graph.dart';
import 'package:kompositum/game/compound_pool_generator.dart';

import '../data/compound.dart';
import 'compound_graph.dart';

class GraphBasedPoolGenerator extends CompoundPoolGenerator {

  late final Future<CompoundGraph> _fullGraph;
  final int rememberLastN;
  final Queue<Compound> _lastNCompounds = Queue();

  GraphBasedPoolGenerator(super.databaseInterface, {this.rememberLastN = 50}) {
    _fullGraph = _getFullGraph();
  }

  Future<CompoundGraph> _getFullGraph() async {
    return CompoundGraph.fromCompounds(await databaseInterface.getAllCompounds());
  }

  @override
  Future<List<Compound>> generateWithoutValidation({required int compoundCount, required CompactFrequencyClass frequencyClass, int? seed}) async {
    final stopWatch = Stopwatch()..start();
    final fullGraph = await _fullGraph;

    var selectableCompounds = await databaseInterface.getCompoundsByCompactFrequencyClass(frequencyClass);
    final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);

    // Remove compounds that were already used in the last N compounds
    for (var compound in _lastNCompounds) {
      selectableGraph.removeCompound(compound);
    }

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

    print("Remaining selectable compounds: ${selectableGraph.getAllComponents().length} (took ${stopWatch.elapsedMilliseconds} ms)");

    _updateLastCompounds(compounds);

    return compounds;
  }

  void _updateLastCompounds(List<Compound> compounds) {
    _lastNCompounds.addAll(compounds);
    final takeCount = max(0, _lastNCompounds.length - rememberLastN);
    for (int i = 0; i < takeCount; i++) {
      _lastNCompounds.removeFirst();
    }
  }
}
