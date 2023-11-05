import 'dart:math';

import 'package:kompositum/data/compound.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/game/compact_frequency_class.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/locator.dart';
import 'package:kompositum/util/random_util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically


import '../../data/mock_database_interface.dart';
import '../../test_data/compounds.dart';

class MockCompoundPoolGenerator extends CompoundPoolGenerator {
  MockCompoundPoolGenerator(databaseInterface, {int blockLastN = 50}) : super(databaseInterface, blockLastN: blockLastN);


  @override
  Future<List<Compound>> generateRestricted({required int compoundCount, required CompactFrequencyClass frequencyClass, List<Compound> blockedCompounds = const [], int? seed}) async {
    var possibleCompounds = await databaseInterface.getCompoundsByCompactFrequencyClass(frequencyClass);
    possibleCompounds = possibleCompounds.where((compound) => !blockedCompounds.contains(compound)).toList();
    final random = seed == null ? Random() : Random(seed);
    final sample = randomSampleWithoutReplacement(possibleCompounds, compoundCount, random: random);
    return Future.value(sample);
  }

}

void main() {
  late CompoundPoolGenerator sut;
  late MockDatabaseInterface databaseInterface;

  setUp(() {
    databaseInterface = MockDatabaseInterface();
    sut = MockCompoundPoolGenerator(databaseInterface);
  });

  group("generate", () {
    test(
      "should throw an error if there are no compounds under the given frequency class",
      () {
        databaseInterface.compounds = [
          Compounds.Apfelkuchen.withCompactFrequencyClass(
              CompactFrequencyClass.medium),
          Compounds.Apfelbaum.withCompactFrequencyClass(
              CompactFrequencyClass.hard),
        ];
        expect(
            sut.generate(
              frequencyClass: CompactFrequencyClass.easy,
              compoundCount: 2,
            ),
            throwsException);
      },
    );

    test(
      "should return the given number of compounds",
      () async {
        databaseInterface.compounds = [
          Compounds.Krankenhaus.withCompactFrequencyClass(
              CompactFrequencyClass.easy),
          Compounds.Apfelbaum.withCompactFrequencyClass(
              CompactFrequencyClass.easy),
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
          Compounds.Krankenhaus.withCompactFrequencyClass(
              CompactFrequencyClass.easy),
          Compounds.Apfelbaum.withCompactFrequencyClass(
              CompactFrequencyClass.medium),
          Compounds.Schneemann.withCompactFrequencyClass(
              CompactFrequencyClass.hard),
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
          Compounds.Krankenhaus.withCompactFrequencyClass(
              CompactFrequencyClass.easy),
          Compounds.Apfelbaum.withCompactFrequencyClass(
              CompactFrequencyClass.medium),
          Compounds.Schneemann.withCompactFrequencyClass(
              CompactFrequencyClass.hard),
        ];
        final compounds = await sut.generate(
          frequencyClass: CompactFrequencyClass.medium,
          compoundCount: 3,
        );
        expect(compounds.length, 2);
      },
    );

    test(
      "should return the same compounds for multiple calls with the same seed",
      () async {
        sut = MockCompoundPoolGenerator(databaseInterface, blockLastN: 0);
        databaseInterface.compounds = [
          Compounds.Krankenhaus,
          Compounds.Apfelbaum,
          Compounds.Schneemann
        ];
        final returnedPools = <Compound>[];
        for (var i = 0; i < 10; i++) {
          final pool = await sut.generate(
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
      "should return different results for multiple calls without a seed",
      () async {
        sut = MockCompoundPoolGenerator(databaseInterface, blockLastN: 0);
        databaseInterface.compounds = [
          Compounds.Krankenhaus,
          Compounds.Apfelbaum
        ];
        final returnedCompounds = [];
        for (var i = 0; i < 10; i++) {
          final pool = await sut.generate(
            frequencyClass: CompactFrequencyClass.easy,
            compoundCount: 2,
          );
          returnedCompounds.add(pool.first);
        }
        expect(returnedCompounds,
            containsAll([Compounds.Krankenhaus, Compounds.Apfelbaum]));
      },
    );
  });

  group("blocking", () {
    test("should return a smaller list if it would lead to repetitions", () async {
      databaseInterface.compounds = [Compounds.Apfelbaum];
      sut = MockCompoundPoolGenerator(databaseInterface, blockLastN: 1);
      final compounds1 = await sut.generate(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      final compounds2 = sut.generate(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      expect(compounds1.length, 1);
      expect(compounds2, throwsException);
    });

    test("should return the same element if rememberLastN is zero", () async {
      databaseInterface.compounds = [Compounds.Apfelbaum];
      sut = MockCompoundPoolGenerator(databaseInterface, blockLastN: 0);
      final compounds1 = await sut.generate(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      final compounds2 = await sut.generate(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      expect(compounds1.length, 1);
      expect(compounds2.length, 1);
    });
  });

  // This is a exploratory test, it does not test a specific behavior
  test(skip: true, "print the generation times for the first 30 levels", () async {
    // Init ffi database
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    setupLocator();
    final poolGenerator = GraphBasedPoolGenerator(locator<DatabaseInterface>());
    final levelProvider = BasicLevelProvider(poolGenerator);

    for (int level = 1; level < 30; level++) {
      final stopwatch = Stopwatch()..start();
      final compounds = await levelProvider.generateCompoundPool(level);
      print("Level $level: ${stopwatch.elapsedMilliseconds}ms");
    }

    expect(true, true);
  });

}
