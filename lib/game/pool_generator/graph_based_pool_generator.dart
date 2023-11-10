import 'dart:math';

import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';

import '../../data/compound.dart';
import '../compact_frequency_class.dart';
import '../compound_graph.dart';

class GraphBasedPoolGenerator extends CompoundPoolGenerator {
  late final Future<CompoundGraph> _fullGraph;

  GraphBasedPoolGenerator(super.databaseInterface, super.keyValueStore,
      {super.blockLastN}) {
    _fullGraph = _getFullGraph();
  }

  Future<CompoundGraph> _getFullGraph() async {
    return CompoundGraph.fromCompounds(
        await databaseInterface.getAllCompounds());
  }

  @override
  Future<List<Compound>> generateRestricted(
      {required int compoundCount,
      required CompactFrequencyClass frequencyClass,
      List<Compound> blockedCompounds = const [],
      int? seed}) async {
    final stopWatch = Stopwatch()..start();
    final fullGraph = await _fullGraph;

    var selectableCompounds = await databaseInterface
        .getCompoundsByCompactFrequencyClass(frequencyClass);
    final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);

    for (final blockedCompound in blockedCompounds) {
      selectableGraph.removeCompound(blockedCompound);
    }

    final compounds = <Compound>[];
    final random = seed == null ? Random() : Random(seed);
    for (int i = 0; i < compoundCount; i++) {
      // print("Selectable compounds: ${selectableGraph.getAllComponents().length}");
      final pair = selectableGraph.getRandomModifierHeadPair(random);
      if (pair == null) {
        break;
      }
      final compound =
          await databaseInterface.getCompoundCaseInsensitive(pair.$1, pair.$2);
      if (compound == null) {
        throw Exception("Compound not found: ${pair.$1}+${pair.$2}");
      }
      compounds.add(compound);
      final conflicts = fullGraph.getConflictingComponents(compound);
      selectableGraph.removeComponents(conflicts);
    }

    print(
        "Remaining selectable compounds: ${selectableGraph.getAllComponents().length} (took ${stopWatch.elapsedMilliseconds} ms)");

    return compounds;
  }
}
