import 'dart:math';

import 'package:kompositum/data/compound.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/game/compact_frequency_class.dart';
import 'package:kompositum/util/random_util.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically


class MockDatabaseInterface implements DatabaseInterface {
  var compounds = <Compound>[];

  @override
  Future<int> getCompoundCount() {
    return Future.value(compounds.length);
  }

  @override
  Future<Compound?> getCompoundCaseInsensitive(String modifier, String head) {
    return Future.value(compounds.firstWhereOrNull((compound) =>
    compound.modifier == modifier && compound.head == head));
  }

  @override
  Future<List<Compound>> getCompoundsByFrequencyClass(
      int? frequencyClass) {
    if (frequencyClass == null) {
      return Future.value(compounds);
    }
    return Future.value(compounds
        .where((compound) => compound.frequencyClass != null && compound.frequencyClass! <= frequencyClass)
        .toList());
  }

  @override
  Future<List<Compound>> getAllCompounds() {
    return Future.value(compounds);
  }

  @override
  Future<List<Compound>> getCompoundsByCompactFrequencyClass(
      CompactFrequencyClass frequencyClass) {
    if (frequencyClass.maxFrequencyClass == null) {
      return Future.value(compounds);
    }
    return Future.value(compounds
        .where((compound) =>
    compound.frequencyClass != null &&
        compound.frequencyClass! <= frequencyClass.maxFrequencyClass!)
        .toList());
  }

  @override
  Future<List<Compound>> getRandomCompounds(
      {required int count, required int? maxFrequencyClass, int? seed}) async {
    final random = seed == null ? Random() : Random(seed);
    final compoundsFiltered = maxFrequencyClass == null
        ? compounds
        : compounds
        .where((compound) => compound.frequencyClass! <= maxFrequencyClass)
        .toList();
    final sample = randomSampleWithoutReplacement(compoundsFiltered, count,
        random: random);
    return Future.value(sample);
  }

  @override
  // TODO: implement databaseInitializer
  DatabaseInitializer get databaseInitializer => throw UnimplementedError();

  @override
  Future<Compound?> getRandomCompoundRestricted({required int? maxFrequencyClass, List<String> forbiddenComponents = const []}) {
    // TODO: implement getRandomCompoundRestricted
    throw UnimplementedError();
  }

  @override
  Future<Compound?> getCompound(String modifier, String head) {
    return Future.value(compounds.firstWhereOrNull((compound) =>
    compound.modifier == modifier && compound.head == head));
  }
}