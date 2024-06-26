import 'dart:math';

import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/classic/generator/classic_level_content.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';
import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/util/extensions/string_util.dart';


class GraphBasedClassicLevelContentGenerator extends LevelContentGenerator<ClassicLevelContent> {
  late final Future<CompoundGraph> _fullGraph;

  GraphBasedClassicLevelContentGenerator(super.databaseInterface,
      {super.blockLastN}) {
    _fullGraph = _getFullGraph();
  }

  Future<CompoundGraph> _getFullGraph() async {
    return CompoundGraph.fromCompounds(
        await databaseInterface.getAllCompounds());
  }

  @override
  Future<ClassicLevelContent> generateRestricted({
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
      var compound = await databaseInterface.getCompoundSafe(pair.$1, pair.$2);
      if (compound == null) {
        // This is really unfortunate, but we have to live with it. Just skip this compound.
        print("Compound not found: ${pair.$1}+${pair.$2}");
        continue;
      }
      compounds.add(compound);
      final conflicts = fullGraph.getConflictingComponents(compound);
      selectableGraph.removeComponents(conflicts);
    }

    stopWatch.stop();
    print(
        "Remaining selectable compounds: ${selectableGraph.getAllComponents().length}"
            " (took ${stopWatch.elapsedMilliseconds} ms)");

    return ClassicLevelContent(compounds);
  }
}
