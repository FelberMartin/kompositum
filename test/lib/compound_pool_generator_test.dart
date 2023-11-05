import 'dart:math';

import 'package:kompositum/data/compound.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/game/compound_pool_generator.dart';
import 'package:kompositum/game/graph_based_pool_generator.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/locator.dart';
import 'package:kompositum/util/random_util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically


import '../test_data/compounds.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {
  var compounds = <Compound>[];

  @override
  Future<int> getCompoundCount() {
    return Future.value(compounds.length);
  }

  @override
  Future<Compound?> getCompound(String modifier, String head) {
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

  group(skip: false, "NoConflictCompoundPoolGenerator", () {
    late NoConflictCompoundPoolGenerator noConflictSut;

    setUp(() {
      noConflictSut = IterativeNoConflictCompoundPoolGenerator(databaseInterface);
    });

    test("should return a smaller pool if there would otherwise be conflicts",
        () async {
      databaseInterface.compounds = [
        Compounds.Apfelkuchen,
        Compounds.Kuchenform,
        Compounds.Formsache
      ];
      final compounds = await noConflictSut.generate(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 3,
      );
      expect(compounds.length, 1);
    });

    group("isConflict", () {
      test(
          "should return true if the components could create another valid compound",
          () {
        final compound = Compounds.Formsache;
        final selectedCompounds = [Compounds.Apfelkuchen];
        final allCompounds = [Compounds.Apfelkuchen, Compounds.Kuchenform, Compounds.Formsache];

        expect(
            noConflictSut.isConflict(
                compound, selectedCompounds, allCompounds),
            true);
      });

      test(
          "should return true if the components could create another valid compound",
              () {
            final compound = Compounds.Formsache;
            final selectedCompounds = [Compounds.Apfelkuchen, Compounds.Kuchenform];
            final allCompounds = [Compounds.Apfelkuchen, Compounds.Kuchenform, Compounds.Formsache];
            expect(
                noConflictSut.isConflict(
                    compound, selectedCompounds, allCompounds),
                true);
          });

      test("should return true for simplicity, if components overlap", () {
        final compound = Compounds.Kuchenform;
        final selectedCompounds = [Compounds.Apfelkuchen];
        final allCompounds = [Compounds.Apfelkuchen, Compounds.Kuchenform, Compounds.Formsache];
        expect(
            noConflictSut.isConflict(
                compound, selectedCompounds, allCompounds), true);
      });

      test("should return false if there is no conflict", () {
        final compound = Compounds.Schneemann;
        final selectedCompounds = [Compounds.Apfelkuchen];
        final allCompounds = [Compounds.Apfelkuchen, Compounds.Schneemann];
        expect(
            noConflictSut.isConflict(
                compound, selectedCompounds, allCompounds), false);
      });
    });
  });

  // ------------------- GraphBasedPoolGenerator -------------------

  group("GraphBasedPoolGenerator", () {
    late CompoundPoolGenerator sut;

    test("should return a smaller pool if there would otherwise be conflicts",
            () async {
          databaseInterface.compounds = [
            Compounds.Apfelkuchen,
            Compounds.Kuchenform,
            Compounds.Formsache
          ];
          sut = GraphBasedPoolGenerator(databaseInterface);
          final compounds = await sut.generate(
            frequencyClass: CompactFrequencyClass.easy,
            compoundCount: 3,
          );
          expect(compounds.length, 1);
        });

    test("should return a smaller list if it would lead to repetitions", () async {
      databaseInterface.compounds = [Compounds.Apfelbaum];
      sut = GraphBasedPoolGenerator(databaseInterface, rememberLastN: 1);
      final compounds1 = await sut.generateWithoutValidation(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      final compounds2 = await sut.generateWithoutValidation(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      final compounds3 = await sut.generateWithoutValidation(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      expect(compounds1.length, 1);
      expect(compounds2.length, 0);
    });

    test("should return the same element if rememberLastN is zero", () async {
      databaseInterface.compounds = [Compounds.Apfelbaum];
      sut = GraphBasedPoolGenerator(databaseInterface, rememberLastN: 0);
      final compounds1 = await sut.generateWithoutValidation(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      final compounds2 = await sut.generateWithoutValidation(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 1,
      );
      expect(compounds1.length, 1);
      expect(compounds2.length, 1);
    });
  });



  // This is a exploratory test, it does not test a specific behavior
  test(skip: false, "print the generation times for the first 30 levels", () async {
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
