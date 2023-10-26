
import 'package:kompositum/data/database.dart';

import 'compound.dart';

class MockDatabase implements DatabaseHelper {

  final List<Compound> compounds = [
    // Create a list of different german compounds without using the same heads or modifiers twice
    Compound(name: "Krankenhaus", modifier: "krank", head: "Haus", frequencyClass: 0),
    Compound(name: "Apfelbaum", modifier: "Apfel", head: "Baum", frequencyClass: 2),
    Compound(name: "Buchladen", modifier: "Buch", head: "Laden", frequencyClass: 2),
    Compound(name: "Hundehütte", modifier: "Hund", head: "Hütte", frequencyClass: 3),
    Compound(name: "Küchenmesser", modifier: "Küche", head: "Messer", frequencyClass: 4),
    Compound(name: "Schlafzimmer", modifier: "Schlaf", head: "Zimmer", frequencyClass: 5),
    Compound(name: "Schreibtisch", modifier: "Schreib", head: "Tisch", frequencyClass: 5),
    Compound(name: "Schuhladen", modifier: "Schuh", head: "Laden", frequencyClass: 5),
    Compound(name: "Schulbus", modifier: "Schul", head: "Bus", frequencyClass: 5),
    Compound(name: "Schulhof", modifier: "Schul", head: "Hof", frequencyClass: 5),
  ];

  @override
  Future<int> countCompounds() async {
    return compounds.length;
  }

  @override
  Future<void> initDatabase() async {
    // Do nothing
  }

  @override
  Future<Compound?> getRandomCompound(int maxFrequencyClass) async {
    final filtered = compounds.where((element) => element.frequencyClass! <= maxFrequencyClass).toList();
    if (filtered.isEmpty) {
      return null;
    }
    filtered.shuffle();
    return filtered.first;
  }

  @override
  Future<List<Compound>> getAllCompounds() async {
    return compounds;
  }

  @override
  Future<Compound?> getCompound(String modifier, String head) async {
    return compounds.firstWhere((element) => element.modifier == modifier && element.head == head);
  }


}