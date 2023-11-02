import 'dart:math';

import 'package:kompositum/compound_pool_generator.dart';
import 'package:kompositum/data/compound.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/random_util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {
  var compounds = <Compound>[];

  @override
  Future<int> getCompoundCount() {
    return Future.value(compounds.length);
  }

  @override
  Future<List<Compound>> getAllCompounds() {
    return Future.value(compounds);
  }

  @override
  Future<List<Compound>> getRandomCompounds(
  {required int count, required int? maxFrequencyClass, int? seed}) async {
    final random = seed == null ? Random() : Random(seed);
    final compoundsFiltered = maxFrequencyClass == null ? compounds :
      compounds.where((compound) => compound.frequencyClass! <= maxFrequencyClass).toList();
    final sample = randomSampleWithoutReplacement(compoundsFiltered, count, random: random);
    return Future.value(sample);
  }
}

void main() {
  late CompoundPoolGenerator sut;
  late MockDatabaseInterface databaseInterface;

  setUp(() {
    databaseInterface = MockDatabaseInterface();
    sut = CompoundPoolGenerator(databaseInterface);
  });

  group("generate", () {
      test(
        "should throw an error if there are no compounds under the given frequency class",
        () {
          databaseInterface.compounds = [
            Compounds.Apfelkuchen.withCompactFrequencyClass(CompactFrequencyClass.medium),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.hard),
          ];
          expect(sut.generate(
            frequencyClass: CompactFrequencyClass.easy,
            compoundCount: 2,
          ), throwsException);
        },
      );

      test(
        "should return the given number of compounds",
        () async {
          databaseInterface.compounds = [
            Compounds.Krankenhaus.withCompactFrequencyClass(CompactFrequencyClass.easy),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.easy),
          ];
          final compounds = await sut.generate(
            frequencyClass: CompactFrequencyClass.easy,
            compoundCount: 2,
          );
          expect(compounds.length, 2);
        },
      );

      test(
        "should return also compounds with frequency classes lower than the given one",
        () async {
          databaseInterface.compounds = [
            Compounds.Krankenhaus.withCompactFrequencyClass(CompactFrequencyClass.easy),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.medium),
            Compounds.Schneemann.withCompactFrequencyClass(CompactFrequencyClass.hard),
          ];
          final compounds = await sut.generate(
            frequencyClass: CompactFrequencyClass.hard,
            compoundCount: 3,
          );
          expect(compounds.length, 3);
        },
      );

      test(
        "should return only compounds with frequency classes lower or equal than the given one",
        () async {
          databaseInterface.compounds = [
            Compounds.Krankenhaus.withCompactFrequencyClass(CompactFrequencyClass.easy),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.medium),
            Compounds.Schneemann.withCompactFrequencyClass(CompactFrequencyClass.hard),
          ];
          final compounds = await sut.generate(
            frequencyClass: CompactFrequencyClass.medium,
            compoundCount: 3,
          );
          expect(compounds.length, 2);
        },
      );

      test(
        "should return the same compounds for multiple calls with the same seed", () async {
          databaseInterface.compounds = [
            Compounds.Krankenhaus, Compounds.Apfelbaum, Compounds.Schneemann
          ];
          final returnedPools = <Compound>[];
          for (var i = 0; i < 10; i++) {
            final pool =
            await sut.generate(
              frequencyClass: CompactFrequencyClass.hard,
              compoundCount: 3,
              seed: 0,
            );
            returnedPools.add(pool.first);
          }
          expect(returnedPools.toSet().length, 1);
        },
      );

      test(
        "should return different results for multiple calls without a seed", () async {
          databaseInterface.compounds = [Compounds.Krankenhaus, Compounds.Apfelbaum];
          final returnedCompounds = [];
          for (var i = 0; i < 10; i++) {
            final pool =
            await sut.generate(
              frequencyClass: CompactFrequencyClass.easy,
              compoundCount: 2,
            );
            returnedCompounds.add(pool.first);
          }
          expect(returnedCompounds, containsAll([Compounds.Krankenhaus, Compounds.Apfelbaum]));
        },
      );

    });
}
