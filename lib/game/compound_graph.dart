import 'dart:math';

import 'package:graph_collection/graph.dart';

import '../data/compound.dart';

class CompoundGraph {

  final DirectedGraph _graph = DirectedGraph();

  static CompoundGraph fromCompounds(List<Compound> compounds) {
    final compoundGraph = CompoundGraph();
    for (final compound in compounds) {
      compoundGraph.addCompound(compound);
    }
    return compoundGraph;
  }

  void addCompound(Compound compound) {
    _graph.linkTo(compound.modifier, compound.head);
  }

  List getAllComponents() {
    return _graph.toList();
  }

  List<String> getConflictingComponents(Compound compound) {
    final modifierNeighbors = getNeighbors(compound.modifier);
    final headNeighbors = getNeighbors(compound.head);
    return [...modifierNeighbors, ...headNeighbors];
  }

  List<String> getNeighbors(String component) {
    final linkedHeads = _graph.linkTos(component).toList();
    final linkedModifiers = _graph.linkFroms(component).toList();
    return [...linkedHeads, ...linkedModifiers];
  }

  void removeCompound(Compound compound) {
    _graph.unLinkTo(compound.modifier, compound.head);
  }

  void removeComponents(List<String> components) {
    for (final component in components) {
      _graph.remove(component);
    }
  }

  (String, String)? getRandomModifierHeadPair(Random random) {
    final allComponents = getAllComponents();
    if (allComponents.isEmpty) {
      return null;
    }
    final component = allComponents[random.nextInt(allComponents.length)];
    final linkedHeads = _graph.linkTos(component).toList();
    if (linkedHeads.isNotEmpty) {
      final head = linkedHeads[random.nextInt(linkedHeads.length)];
      return (component, head);
    }
    final linkedModifiers = _graph.linkFroms(component).toList();
    if (linkedModifiers.isNotEmpty) {
      final modifier = linkedModifiers[random.nextInt(linkedModifiers.length)];
      return (modifier, component);
    }

    removeComponents([component]);
    return getRandomModifierHeadPair(random);
  }

}