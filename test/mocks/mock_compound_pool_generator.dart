import 'dart:math';

import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/level_content_generator.dart';
import 'package:kompositum/game/modi/classic/generator/classic_level_content.dart';
import 'package:kompositum/util/extensions/random_util.dart';
import 'package:mocktail/mocktail.dart';


class MockCompoundPoolGenerator extends Mock implements LevelContentGenerator<ClassicLevelContent> {
  @override
  List<Compound> getBlockedCompounds() {
    return [];
  }

  @override
  Future<void> setBlockedCompounds(List<String> blockedCompoundNames) {
    return Future.value();
  }
}


class SimpleTestCompoundPoolGenerator extends LevelContentGenerator {
  SimpleTestCompoundPoolGenerator(super.databaseInterface,
      {super.blockLastN});

  @override
  Future<ClassicLevelContent> generateRestricted(
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
    return Future.value(ClassicLevelContent(sample));
  }
}