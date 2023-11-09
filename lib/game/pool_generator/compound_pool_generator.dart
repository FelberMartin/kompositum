import 'dart:collection';
import 'dart:math';

import 'package:kompositum/data/database_interface.dart';

import '../../data/compound.dart';
import '../compact_frequency_class.dart';
import '../level_provider.dart';

abstract class CompoundPoolGenerator {
  final DatabaseInterface databaseInterface;

  final int blockLastN;
  final Queue<Compound> _blockedCompounds = Queue();

  CompoundPoolGenerator(this.databaseInterface, {this.blockLastN = 50});

  Future<List<Compound>> generateFromLevelSetup(LevelSetup levelSetup) {
    return generate(
      compoundCount: levelSetup.compoundCount,
      frequencyClass: levelSetup.frequencyClass,
      seed: levelSetup.poolGenerationSeed,
    );
  }

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

    final blockedCompounds = _blockedCompounds.toList();
    List<Compound> compounds = await generateRestricted(
        compoundCount: compoundCount,
        frequencyClass: frequencyClass,
        blockedCompounds: blockedCompounds,
        seed: seed);

    _updateBlockedCompounds(compounds);

    if (compounds.isEmpty) {
      throw Exception("No compounds found for the given frequency class");
    }
    if (compounds.length < compoundCount) {
      print("Not enough compounds found with out clashes. "
          "Only ${compounds.length} of $compoundCount compounds found.");
    }
    return compounds;
  }

  Future<List<Compound>> generateRestricted(
      {required int compoundCount,
      required CompactFrequencyClass frequencyClass,
      List<Compound> blockedCompounds = const [],
      int? seed});

  void _updateBlockedCompounds(List<Compound> compounds) {
    _blockedCompounds.addAll(compounds);
    final removeCount = max(0, _blockedCompounds.length - blockLastN);
    for (int i = 0; i < removeCount; i++) {
      _blockedCompounds.removeFirst();
    }
  }
}
