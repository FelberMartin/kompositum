import 'dart:math';

import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/pool/generator/compound_pool_generator.dart';
import 'package:kompositum/util/random_util.dart';
import 'package:mocktail/mocktail.dart';


class MockCompoundPoolGenerator extends Mock implements CompoundPoolGenerator {
  @override
  List<Compound> getBlockedCompounds() {
    return [];
  }

  @override
  Future<void> setBlockedCompounds(List<String> blockedCompoundNames) {
    return Future.value();
  }
}


class SimpleTestCompoundPoolGenerator extends CompoundPoolGenerator {
  SimpleTestCompoundPoolGenerator(super.databaseInterface,
      {super.blockLastN});

  @override
  Future<List<Compound>> generateRestricted(
      {required int compoundCount,
        required CompactFrequencyClass frequencyClass,
        List<Compound> blockedCompounds = const [],
        int? seed}) async {
    var possibleCompounds = await databaseInterface
        .getCompoundsByCompactFrequencyClass(frequencyClass);
    possibleCompounds = possibleCompounds
        .where((compound) => !blockedCompounds.contains(compound))
        .toList();
    final random = seed == null ? Random() : Random(seed);
    final sample = randomSampleWithoutReplacement(
        possibleCompounds, compoundCount,
        random: random);
    return Future.value(sample);
  }
}