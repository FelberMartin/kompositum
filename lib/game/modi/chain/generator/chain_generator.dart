import 'dart:math';

import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';

import '../../../../data/models/compact_frequency_class.dart';
import '../../../../data/models/compound.dart';

class ChainGenerator extends LevelContentGenerator<ComponentChain> {

  static const int maxIterations = 8;

  late final Future<CompoundGraph> _fullGraph;

  ChainGenerator(super.databaseInterface) {
    _fullGraph = _getFullGraph();
  }

  Future<CompoundGraph> _getFullGraph() async {
    return CompoundGraph.fromCompounds(
        await databaseInterface.getAllCompounds());
  }

  @override
  Future<ComponentChain> generateRestricted({required int compoundCount,
    required CompactFrequencyClass frequencyClass,
    List<Compound> blockedCompounds = const [],
    int? seed
  }) async {
    final fullGraph = await _fullGraph;
    final selectableCompounds = await databaseInterface
        .getCompoundsByCompactFrequencyClass(frequencyClass);
    final random = Random(seed);
    final maxChainLength = compoundCount + 1;

    final bestChain = <String>[];
    int iteration = 0;
    while (bestChain.length < maxChainLength) {
      final selectableGraph = CompoundGraph.fromCompounds(selectableCompounds);
      selectableGraph.removeCompounds(blockedCompounds);

      final startString = selectableGraph.getRandomComponent(random)!;
      final componentStrings = getBestChainForStartString(
        startString: startString,
        selectableGraph: selectableGraph,
        conflictsGraph: fullGraph,
        random: random,
        maxChainLength: maxChainLength,
      );

      if (componentStrings.length > bestChain.length) {
        bestChain.clear();
        bestChain.addAll(componentStrings);
      }

      print("Iteration $iteration: Chain length ${componentStrings.length} of $maxChainLength [$startString]");
      iteration++;
      if (iteration > maxIterations) {
        print("Max iterations reached");
        break;
      }
    }

    return ComponentChain.fromLowercaseComponentStrings(
        componentStrings: bestChain,
        databaseInterface: databaseInterface,
    );
  }

  List<String> getBestChainForStartString({
    required String startString,
    required CompoundGraph selectableGraph,
    required CompoundGraph conflictsGraph,
    required Random random,
    required int maxChainLength,
  }) {
    final componentStrings = <String>[startString];
    final bestChain = <String>[];

    while (bestChain.length < maxChainLength) {
      final modifier = componentStrings.last;
      final head = selectableGraph.getRandomHeadForModifier(modifier: modifier, random: random);
      if (head == null) {
        // if (componentStrings.length > 1) {
        //   componentStrings.removeLast();
        // } else {
        //   // Only the start string is left
        //   break;
        // }
        break;
      } else {
        componentStrings.add(head);
        if (componentStrings.length > bestChain.length) {
          bestChain.clear();
          bestChain.addAll(componentStrings);
        }
      }
      final conflicts = conflictsGraph.getNeighbors(modifier);
      conflicts.remove(head);
      selectableGraph.removeComponents(conflicts);
    }

    return bestChain;
  }

}
