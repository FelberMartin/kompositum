
import 'package:kompositum/data/database_interface.dart';

import '../data/compound.dart';

class Swappable {
  final Compound original;
  final Compound swapped;

  Swappable(this.original, this.swapped);
}

class SwappableDetector {
  final DatabaseInterface databaseInterface;

  SwappableDetector(this.databaseInterface);

  Future<List<Swappable>> getSwappables(List<Compound> compounds) async {
    final swappables = <Swappable>[];
    for (var compound in compounds) {
      final swappable = await _getSwappable(compound);
      if (swappable != null) {
        swappables.add(swappable);
      }
    }
    return swappables;
  }

  Future<Swappable?> _getSwappable(Compound compound) async {
    final swapped = await databaseInterface.getCompound(compound.head, compound.modifier);
    if (swapped != null) {
      return Swappable(compound, swapped);
    }
  }
}