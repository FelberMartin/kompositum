import 'dart:math';

import 'package:kompositum/data/database_interface.dart';

import 'data/compound.dart';

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

    final compounds = await databaseInterface.getRandomCompounds(
      count: compoundCount,
      maxFrequencyClass: frequencyClass.maxFrequencyClass,
      seed: seed,
    );

    if (compounds.isEmpty) {
      throw Exception("No compounds found for the given frequency class");
    }
    if (compounds.length < compoundCount) {
      print("Not enough compounds found with out clashes. "
          "Only ${compounds.length} of $compoundCount compounds found.");
    }
    return compounds;
  }

}