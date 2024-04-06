import 'dart:collection';
import 'dart:math';

import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/util/random_util.dart';
import 'package:kompositum/util/string_util.dart';

import '../../data/models/compact_frequency_class.dart';
import '../../data/models/compound.dart';
import '../pool_generator/compound_graph.dart';

class ComponentChain {
  final List<UniqueComponent> components;
  final List<Compound> compounds;

  ComponentChain(this.components, this.compounds);

  static Future<ComponentChain> fromLowercaseComponentStrings({
    required List<String> componentStrings,
    required DatabaseInterface databaseInterface,
  }) async {
    final components = <UniqueComponent>[];
    final compounds = <Compound>[];

    for (int i = 0; i < componentStrings.length - 1; i++) {
      final modifier = componentStrings[i];
      final head = componentStrings[i + 1];
      final compound = await databaseInterface.getCompound(modifier, head, caseSensitive: false);
      compounds.add(compound!);
      components.add(UniqueComponent(compound.modifier));
    }

    final lastComponent = UniqueComponent(compounds.last.head);
    components.add(lastComponent);
    return ComponentChain(components, compounds);
  }


  @override
  String toString() {
    return components.map((component) => component.text).join(" ");
  }

}

class ChainGenerator {
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
