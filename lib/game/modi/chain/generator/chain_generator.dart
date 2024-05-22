import 'dart:math';

import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';

import '../../../../data/models/compact_frequency_class.dart';
import '../../../../data/models/compound.dart';

class ChainGenerator extends LevelContentGenerator<ComponentChain> {

  ChainGenerator(super.databaseInterface);

  @override
  Future<ComponentChain> generateRestricted({required int compoundCount,
    required CompactFrequencyClass frequencyClass,
    List<Compound> blockedCompounds = const [],
    int? seed
  }) async {

    var selectableCompounds = await databaseInterface
        .getCompoundsByCompactFrequencyClass(frequencyClass);
    final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);
    final random = Random(seed);

    final componentStrings = <String>[];
    int iteration = 0;
    while (componentStrings.length < compoundCount) {
      componentStrings.clear();
      final startString = selectableGraph.getRandomComponent(random)!;
      componentStrings.add(startString);
      for (int i = 0; i < compoundCount; i++) {
        final modifier = componentStrings.last;
        final head = selectableGraph.getRandomHeadForModifier(modifier: modifier, random: random);
        if (head == null) {
          // TODO: improvement: instead of stopping early, remove the last component and try again
          break;
        }
        componentStrings.add(head);
        // TODO: remove conflicts
      }
      print("Iteration $iteration: Chain length ${componentStrings.length} of $compoundCount");
      iteration++;
    }

    return ComponentChain.fromLowercaseComponentStrings(
        componentStrings: componentStrings,
        databaseInterface: databaseInterface,
    );
  }

}
