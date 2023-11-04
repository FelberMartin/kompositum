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
    final allCompounds = await databaseInterface.getCompoundsByFrequencyClass(18);
    final graph = CompoundGraph.fromCompounds(allCompounds);

    final compounds = <Compound>[];
    final random = seed == null ? Random() : Random(seed);
    for (int i = 0; i < compoundCount; i++) {
      final compoundsWithoutConflict = graph.getCompounds();
      final selectableCompounds = compoundsWithoutConflict
          .where((compound) =>
              compound.frequencyClass != null &&
              compound.frequencyClass! <= frequencyClass.maxFrequencyClass!)
          .toList();
      if (selectableCompounds.isEmpty) {
        break;
      }
      final compound =
          selectableCompounds[random.nextInt(selectableCompounds.length)];
      compounds.add(compound);
      graph.removeCompoundAndConflicts(compound);
    }

    return compounds;
  }
}
