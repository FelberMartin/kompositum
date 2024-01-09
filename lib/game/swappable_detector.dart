
import 'package:kompositum/data/database_interface.dart';

import '../data/models/compound.dart';

class Swappable {
  final Compound original;
  final Compound swapped;

  Swappable(this.original, this.swapped);

  static Swappable fromJson(Map<String, dynamic> json) {
    return Swappable(
      Compound.fromJson(json['original']),
      Compound.fromJson(json['swapped']),
    );
  }

  Map<String, dynamic> toJson() => {
    'original': original.toJson(),
    'swapped': swapped.toJson(),
  };

  @override
  String toString() {
    return 'Swappable{original: $original, swapped: $swapped}';
  }

  @override
  bool operator ==(Object other) {
    return other is Swappable && other.original == original && other.swapped == swapped;
  }

  @override
  int get hashCode => original.hashCode ^ swapped.hashCode;
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