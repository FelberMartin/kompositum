import 'dart:math';

import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';
import 'package:kompositum/game/modi/classic/generator/compound_pool_generator.dart';
import 'package:kompositum/util/string_util.dart';


class GraphBasedPoolGenerator extends CompoundPoolGenerator<List<Compound>> {
  late final Future<CompoundGraph> _fullGraph;

  GraphBasedPoolGenerator(super.databaseInterface,
      {super.blockLastN}) {
    _fullGraph = _getFullGraph();
  }

  Future<CompoundGraph> _getFullGraph() async {
    return CompoundGraph.fromCompounds(
        await databaseInterface.getAllCompounds());
  }

  @override
  Future<List<Compound>> generateRestricted({
    required int compoundCount,
    required CompactFrequencyClass frequencyClass,
    List<Compound> blockedCompounds = const [],
    int? seed
  }) async {
    final stopWatch = Stopwatch()..start();
    final fullGraph = await _fullGraph;

    var selectableCompounds = await databaseInterface
        .getCompoundsByCompactFrequencyClass(frequencyClass);
    final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);
    selectableGraph.removeCompounds(blockedCompounds);

    final compounds = <Compound>[];
    final random = seed == null ? Random() : Random(seed);
    for (int i = 0; i < compoundCount; i++) {
      // print("Selectable compounds: ${selectableGraph.getAllComponents().length}");
      final pair = selectableGraph.getRandomModifierHeadPair(random);
      if (pair == null) {
        break;
      }
      var compound =
          await databaseInterface.getCompound(pair.$1, pair.$2, caseSensitive: false);
      if (compound == null) {
        // This may happen due to the problem with the case sensitivity and umlauts.
        // See also the comment in database_interface.getCompound.
        compound = await databaseInterface.getCompound(pair.$1.capitalize(),
            pair.$2.capitalize(), caseSensitive: false);
        if (compound == null) {
          // This is really unfortunate, but we have to live with it. Just skip this compound.
          print("Compound not found: ${pair.$1}+${pair.$2}");
          continue;
        }
      }
      compounds.add(compound);
      final conflicts = fullGraph.getConflictingComponents(compound);
      selectableGraph.removeComponents(conflicts);
    }

    stopWatch.stop();
    print(
        "Remaining selectable compounds: ${selectableGraph.getAllComponents().length}"
            " (took ${stopWatch.elapsedMilliseconds} ms)");

    return compounds;
  }
}
