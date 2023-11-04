import 'package:graph_collection/graph.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically

import '../data/compound.dart';

class CompoundGraph {

  final DirectedGraph _graph = DirectedGraph();
  final Map<String, List<MapEntry<String, Compound>>> _modifierToHeadToCompound = {};
  final List<Compound> _compounds = [];

  static CompoundGraph fromCompounds(List<Compound> compounds) {
    final compoundGraph = CompoundGraph();
    for (final compound in compounds) {
      compoundGraph.addCompound(compound);
    }
    return compoundGraph;
  }

  void addCompound(Compound compound) {
    _graph.linkTo(compound.modifier, compound.head);
    _modifierToHeadToCompound.putIfAbsent(compound.modifier, () => []).add(MapEntry(compound.head, compound));
    _compounds.add(compound);
  }

  void removeCompound(Compound compound) {
    if (!_compounds.contains(compound)) {
      return;
    }
    _graph.unLinkTo(compound.modifier, compound.head);
    _modifierToHeadToCompound[compound.modifier]!.removeWhere((entry) => entry.value == compound);
    _compounds.remove(compound);
  }

  List<Compound> getCompounds() {
    return _compounds;
  }

  void removeComponent(String component) {
    final linkedHeads = _graph.linkTos(component).toList();
    for (final head in linkedHeads) {
      final compound = getCompound(component, head);
      removeCompound(compound!);
    }

    final linkedModifiers = _graph.linkFroms(component).toList();
    for (final modifier in linkedModifiers) {
      final compound = getCompound(modifier, component);
      removeCompound(compound!);
    }
  }

  List<String> getNeighbors(String component) {
    final linkedHeads = _graph.linkTos(component).toList();
    final linkedModifiers = _graph.linkFroms(component).toList();
    return [...linkedHeads, ...linkedModifiers];
  }

  void removeCompoundAndConflicts(Compound compound) {
    final modifierNeighbors = getNeighbors(compound.modifier);
    final headNeighbors = getNeighbors(compound.head);
    for (final neighbor in [...modifierNeighbors, ...headNeighbors]) {
      removeComponent(neighbor);
    }
    removeCompound(compound);
  }

  Compound? getCompound(String modifier, String head) {
    final compounds = _modifierToHeadToCompound[modifier];
    if (compounds == null) {
      return null;
    }
    final compound = compounds.firstWhereOrNull((entry) => entry.key == head);
    return compound?.value;
  }

}