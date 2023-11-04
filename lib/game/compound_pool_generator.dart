import 'dart:math';

import 'package:kompositum/data/database_interface.dart';

import '../data/compound.dart';

enum CompactFrequencyClass {
  easy(12),
  medium(16),
  hard(20);

  const CompactFrequencyClass(this.maxFrequencyClass);

  final int? maxFrequencyClass;
}

class CompoundPoolGenerator {

  final DatabaseInterface databaseInterface;

  CompoundPoolGenerator(this.databaseInterface);

  Future<List<Compound>> generate({
    required CompactFrequencyClass frequencyClass,
    required int compoundCount,
    int? seed,
  }) async {
    assert(compoundCount > 0);

    final count = await databaseInterface.getCompoundCount();
    if (count < compoundCount) {
      throw Exception("Not enough compounds in database. "
          "Only $count compounds found, but $compoundCount compounds required.");
    }

    List<Compound> compounds = await generateWithoutValidation(compoundCount, frequencyClass, seed);

    if (compounds.isEmpty) {
      throw Exception("No compounds found for the given frequency class");
    }
    if (compounds.length < compoundCount) {
      print("Not enough compounds found with out clashes. "
          "Only ${compounds.length} of $compoundCount compounds found.");
    }
    return compounds;
  }

  Future<List<Compound>> generateWithoutValidation(int compoundCount, CompactFrequencyClass frequencyClass, int? seed) async {
    final compounds = await databaseInterface.getRandomCompounds(
      count: compoundCount,
      maxFrequencyClass: frequencyClass.maxFrequencyClass,
      seed: seed,
    );
    return compounds;
  }

}

class NoConflictCompoundPoolGenerator extends CompoundPoolGenerator {

  NoConflictCompoundPoolGenerator(DatabaseInterface databaseInterface) : super(databaseInterface);

  @override
  Future<List<Compound>> generateWithoutValidation(int compoundCount, CompactFrequencyClass frequencyClass, int? seed) async {
    // measure the time it takes to generate the compounds
    final stopwatch = Stopwatch()..start();
    final allCompounds = await databaseInterface.getAllCompounds();
    final allSelectableCompounds = await databaseInterface.getCompoundsByCompactFrequencyClass(frequencyClass);
    final random = seed == null ? Random() : Random(seed);

    final selectedCompounds = <Compound>[];
    for (int i = 0; i < compoundCount; i++) {
      final compound = findCompoundWithoutConflicts(selectedCompounds, allSelectableCompounds, allCompounds, random);
      if (compound == null) {
        continue;
      }
      selectedCompounds.add(compound);
    }

    // print("Generated compounds in ${stopwatch.elapsedMilliseconds}ms");

    return selectedCompounds;
  }

  Compound? findCompoundWithoutConflicts(List<Compound> selectedCompounds, List<Compound> allSelectableCompounds, List<Compound> allCompounds, Random random) {
    const tries = 10;
    // print("---------------------------");
    // print("SelectedCompounds: ${selectedCompounds.map((compound) => compound.name)}");
    // print("AllCompounds: ${allCompounds.map((compound) => compound.name)}");
    for (int i = 0; i < tries; i++) {
      final randomCompound = allSelectableCompounds[random.nextInt(allSelectableCompounds.length)];
      if (selectedCompounds.contains(randomCompound)) {
        continue;
      }
      if (isConflict(randomCompound, selectedCompounds, allCompounds)) {
        continue;
      }
      // print("Found compound without conflict: ${randomCompound.name}");
      return randomCompound;
    }
    // print("No compound without conflict found");
    return null;
  }

  bool isConflict(Compound compound, List<Compound> selectedCompounds, List<Compound> allCompounds) {
    final otherCompounds = allCompounds.where((otherCompound) => otherCompound != compound).toList();
    final [modifier1, head1] = compound.getComponents();
    for (final selectedCompound in selectedCompounds) {
      final [modifier2, head2] = selectedCompound.getComponents();
      final isConflict = isInList(modifier1, modifier2, otherCompounds)
          || isInList(modifier1, head2, otherCompounds)
          || isInList(head1, modifier2, otherCompounds)
          || isInList(head1, head2, otherCompounds)

          || isInList(modifier2, modifier1, otherCompounds)
          || isInList(modifier2, head1, otherCompounds)
          || isInList(head2, modifier1, otherCompounds)
          || isInList(head2, head1, otherCompounds);
      if (isConflict) {
        // print("Conflict with: ${compound.name} ${selectedCompound.name}");
        return true;
      }
    }
    return false;
  }

  bool isInList(String modifier, String head, List<Compound> compounds) {
    final conflict = compounds.any((compound) => compound.modifier == modifier && compound.head == head);
    if (conflict) {
      // print("because: $modifier $head");
    }
    return conflict;
  }

}

class IterativeNoConflictCompoundPoolGenerator extends NoConflictCompoundPoolGenerator {
  IterativeNoConflictCompoundPoolGenerator(super.databaseInterface);

  @override
  Future<List<Compound>> generateWithoutValidation(int compoundCount, CompactFrequencyClass frequencyClass, int? seed) async {
    final allCompounds = await databaseInterface.getCompoundsByFrequencyClass(18);
    final allSelectableCompounds = await databaseInterface.getCompoundsByCompactFrequencyClass(frequencyClass);
    final random = seed == null ? Random() : Random(seed);

    final selectedCompounds = <Compound>[];
    const iterations = 4;
    for (int i = 0; i < iterations; i++) {
      fillWithRandomCompounds(selectedCompounds, compoundCount, allSelectableCompounds, random);
      removeConflicts(selectedCompounds, allSelectableCompounds, allCompounds);
      if (selectedCompounds.length == compoundCount) {
        break;
      }
    }

    return selectedCompounds;
  }

  void removeConflicts(List<Compound> selectedCompounds, List<Compound> allSelectableCompounds, List<Compound> allCompounds) {
    final selectedCompoundsCopy = List<Compound>.from(selectedCompounds);
    for (final compound in selectedCompoundsCopy) {
      final otherSelectedCompounds = selectedCompounds.where((otherCompound) => otherCompound != compound).toList();
      if (isConflict(compound, otherSelectedCompounds, allCompounds)) {
        selectedCompounds.remove(compound);
        allSelectableCompounds.remove(compound);
      }
    }
  }

  void fillWithRandomCompounds(List<Compound> selectedCompounds, int compoundCount, List<Compound> allSelectableCompounds, Random random) {
    while (selectedCompounds.length < compoundCount) {
      if (allSelectableCompounds.isEmpty) {
        break;
      }
      final compound = allSelectableCompounds[random.nextInt(allSelectableCompounds.length)];
      selectedCompounds.add(compound);
      allSelectableCompounds.remove(compound);
    }
  }
}