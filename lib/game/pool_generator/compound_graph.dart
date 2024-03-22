import 'dart:math';

import 'package:graph_collection/graph.dart';

import '../../data/models/compound.dart';

/// A graph that represents compounds. Each compound is represented by a modifier
/// and a head. The graph is directed, with the modifier pointing to the head.
/// To reduce the number of reported compounds, the graph is case insensitive.
class CompoundGraph {

  final DirectedGraph _graph = DirectedGraph();

  static CompoundGraph fromCompounds(List<Compound> compounds) {
    final compoundGraph = CompoundGraph();
    for (final compound in compounds) {
      compoundGraph.addCompound(compound);
    }
    return compoundGraph;
  }

  /// Hint: This method is idempotent. That is, adding the same compound twice
  /// will not change the graph.
  void addCompound(Compound compound) {
    _graph.linkTo(compound.modifier.toLowerCase(), compound.head.toLowerCase());
  }

  /// For testing only.
  bool hasLink(String from, String to) {
    return _graph.hasLinkTo(from, to);
  }

  List getAllComponents() {
    return _graph.toList();
  }

  List<String> getConflictingComponents(Compound compound) {
    final modifierNeighbors = getNeighbors(compound.modifier.toLowerCase());
    final headNeighbors = getNeighbors(compound.head.toLowerCase());
    return [...modifierNeighbors, ...headNeighbors];
  }

  List<String> getNeighbors(String component) {
    final lcComponent = component.toLowerCase();
    final linkedHeads = _graph.linkTos(lcComponent).toList();
    final linkedModifiers = _graph.linkFroms(lcComponent).toList();
    return [...linkedHeads, ...linkedModifiers];
  }

  void removeCompounds(List<Compound> compounds) {
    for (final compound in compounds) {
      removeCompound(compound);
    }
  }

  void removeCompound(Compound compound) {
    _graph.unLinkTo(compound.modifier.toLowerCase(), compound.head.toLowerCase());
  }

  void removeComponents(List<String> components) {
    for (final component in components) {
      _graph.remove(component.toLowerCase());
    }
  }

  /// Returns a random pair of a modifier and a head in the graph.
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