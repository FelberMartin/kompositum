import 'dart:collection';
import 'dart:math';

import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/level_content.dart';
import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/modi/classic/generator/classic_level_content.dart';


abstract class LevelContentGenerator<T extends LevelContent> {
  final DatabaseInterface databaseInterface;

  final int blockLastN;
  final Queue<Compound> _blockedCompounds = Queue();

  LevelContentGenerator(this.databaseInterface,
      {this.blockLastN = 50});

  Future<T> generateFromLevelSetup(LevelSetup levelSetup) async {
    if (levelSetup.levelType == LevelType.mainClassic && levelSetup.levelIdentifier == 1) {
      // final wortschatz = await databaseInterface.getCompoundByName("Wortschatz");
      final wortschatz = await databaseInterface.getCompoundByName("word salad");
      assert(T == ClassicLevelContent);
      return ClassicLevelContent([wortschatz!]) as T;
    }
    return generate(
      compoundCount: levelSetup.compoundCount,
      frequencyClass: levelSetup.difficulty.frequencyClass,
      seed: levelSetup.poolGenerationSeed,
      ignoreBlockedCompounds: levelSetup.ignoreBlockedCompounds,
    );
  }

  Future<T> generate({
    required CompactFrequencyClass frequencyClass,
    required int compoundCount,
    int? seed,
    bool ignoreBlockedCompounds = false,
  }) async {
    assert(compoundCount > 0);

    final count = await databaseInterface.getCompoundCount();
    if (count < compoundCount) {
      throw Exception("Not enough compounds in database. "
          "Only $count compounds found, but $compoundCount compounds required.");
    }

    final blockedCompounds = _blockedCompounds.toList();
    T levelContent = await generateRestricted(
        compoundCount: compoundCount,
        frequencyClass: frequencyClass,
        blockedCompounds: ignoreBlockedCompounds ? [] : blockedCompounds,
        seed: seed);

    final compounds = levelContent.getCompounds();
    if (!ignoreBlockedCompounds) {
      _updateBlockedCompounds(compounds);
    }

    if (compounds.isEmpty) {
      throw Exception("No compounds found for the given frequency class");
    }
    if (compounds.length < compoundCount) {
      print("Not enough compounds found with out clashes. "
          "Only ${compounds.length} of $compoundCount compounds found.");
    }
    return levelContent;
  }

  Future<T> generateRestricted(
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

  Future<void> setBlockedCompounds(List<String> blockedCompoundNames) async {
    _blockedCompounds.clear();
    for (final blockedCompoundName in blockedCompoundNames) {
      final compound = await databaseInterface.getCompoundByName(blockedCompoundName);
      if (compound != null) {
        _blockedCompounds.add(compound);
      }
    }
  }

  List<Compound> getBlockedCompounds() {
    return _blockedCompounds.toList();
  }
}
