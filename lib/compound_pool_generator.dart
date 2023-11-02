import 'package:kompositum/data/database_interface.dart';

import 'data/compound.dart';

enum CompactFrequencyClass {
  easy(15),
  medium(18),
  hard(null);

  const CompactFrequencyClass(this.maxFrequencyClass);

  final int? maxFrequencyClass;
}

class CompoundPoolGenerator {

  final DatabaseInterface databaseInterface;

  CompoundPoolGenerator(this.databaseInterface);

  Future<List<Compound>> generate({
    required CompactFrequencyClass frequencyClass,
    required int compoundCount,
  }) async {
    assert(compoundCount > 0);
    final List<Compound> compounds = [];
    final List<String> forbiddenComponents = [];

    final count = await databaseInterface.getAllCompounds().then((value) => value.length);
    if (count < compoundCount) {
      throw Exception("Not enough compounds in database. "
          "Only $count compounds found, but $compoundCount compounds required.");
    }

    for (var i = 0; i < compoundCount; i++) {
      print("Generating compound ${i + 1} of $compoundCount");
      final compound = await databaseInterface.getRandomCompoundRestricted(
        maxFrequencyClass: frequencyClass.maxFrequencyClass,
        forbiddenComponents: forbiddenComponents,
      );
      if (compound != null) {
        compounds.add(compound);
        forbiddenComponents.add(compound.modifier);
        forbiddenComponents.add(compound.head);
      }
    }

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