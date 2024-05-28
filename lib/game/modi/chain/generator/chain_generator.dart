import 'dart:math';

import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/modi/chain/generator/component_chain.dart';
import 'package:kompositum/game/modi/classic/generator/compound_graph.dart';

import '../../../../data/models/compact_frequency_class.dart';
import '../../../../data/models/compound.dart';

class ChainGenerator extends LevelContentGenerator<ComponentChain> {

  static const int maxIterations = 15;

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
        blockedComponents: [],
        random: random,
        maxChainLength: maxChainLength,
      );

      if (componentStrings.length > bestChain.length) {
        bestChain.clear();
        bestChain.addAll(componentStrings);
      }

      print("Iteration $iteration: Chain length ${componentStrings.length} of $maxChainLength $componentStrings");
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
    required List<String> blockedComponents,
    required Random random,
    required int maxChainLength,
  }) {
    if (maxChainLength == 1) {
      return [startString];
    }

    // To prevent infinite loops, we block the start string
    blockedComponents = [...blockedComponents, startString];

    final head = selectableGraph.getRandomHeadForModifier(
        modifier: startString,
        blockedHeads: blockedComponents,
        random: random
    );
    if (head == null) {
      return [startString];
    }

    final conflicts = conflictsGraph.getLinkedHeads(startString);

    final continuation = getBestChainForStartString(
      startString: head,
      selectableGraph: selectableGraph,
      conflictsGraph: conflictsGraph,
      blockedComponents: [...blockedComponents, ...conflicts],
      random: random,
      maxChainLength: maxChainLength - 1,
    );

    // Best case: the continuation is as long as the maximum chain length
    if (continuation.length == maxChainLength - 1) {
      return [startString, ...continuation];
    }

    // Otherwise, try to find a better continuation
    final alternative = getBestChainForStartString(
      startString: startString,
      selectableGraph: selectableGraph,
      conflictsGraph: conflictsGraph,
      blockedComponents: [...blockedComponents, head],
      random: random,
      maxChainLength: maxChainLength,
    );

    if (alternative.length > continuation.length) {
      return alternative;
    }
    return [startString, ...continuation];
  }

}
