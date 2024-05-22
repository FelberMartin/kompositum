import 'dart:math';

import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';

import '../../../../data/models/compact_frequency_class.dart';
import '../../../../data/models/compound.dart';

class ChainGenerator extends {
  final DatabaseInterface databaseInterface;

  ChainGenerator(this.databaseInterface);


  Future<ComponentChain> generate({
    required int compoundCount,
    required CompactFrequencyClass frequencyClass,
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
