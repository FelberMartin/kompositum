import 'dart:math';

import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:kompositum/util/random_util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../config/test_locator.dart';
import '../../data/mock_database_interface.dart';
import '../../test_data/compounds.dart';

class MockCompoundPoolGenerator extends CompoundPoolGenerator {
  MockCompoundPoolGenerator(super.databaseInterface,
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

class MockKeyValueStore extends Mock implements KeyValueStore {
  final _blockedCompounds = <Compound>[];

  @override
  Future<List<Compound>> getBlockedCompounds(
      Future<Compound?> Function(String) nameToCompound) {
    return Future.value(_blockedCompounds);
  }

  @override
  Future<void> storeBlockedCompounds(List<Compound> compounds) {
    _blockedCompounds.clear();
    _blockedCompounds.addAll(compounds);
    return Future.value();
  }
}

void main() {
  runGeneralPoolGeneratorTests((databaseInterface,
          {int blockLastN = 50}) =>
      MockCompoundPoolGenerator(
          databaseInterface,
          blockLastN: blockLastN));
}

void runGeneralPoolGeneratorTests(
    Function(DatabaseInterface, {int blockLastN}) createSut
) {
  late CompoundPoolGenerator sut;
  late MockDatabaseInterface databaseInterface;

  setUp(() {
    databaseInterface = MockDatabaseInterface();
    sut = createSut(databaseInterface, blockLastN: 0);
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
        sut = createSut(databaseInterface, blockLastN: 0);
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
        sut = createSut(databaseInterface, blockLastN: 0);
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
        sut = createSut(databaseInterface, blockLastN: 0);
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
        sut = createSut(databaseInterface, blockLastN: 0);
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
        sut = createSut(databaseInterface, blockLastN: 0);
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
        sut = createSut(databaseInterface, blockLastN: 0);

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
    test("should return a smaller list if it would lead to repetitions",
        () async {
      databaseInterface.compounds = [Compounds.Apfelbaum];
      sut = createSut(databaseInterface, blockLastN: 1);
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
      sut = createSut(databaseInterface, blockLastN: 0);
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

    test("should set the compounds via the given list of names", () async {
      databaseInterface.compounds = [Compounds.Apfelbaum];
      sut = createSut(databaseInterface, blockLastN: 0);
      await sut.setBlockedCompounds(["Apfelbaum"]);
      final blockedCompounds = sut.getBlockedCompounds();
      expect(blockedCompounds, [Compounds.Apfelbaum]);
    });
  });

  test("Should return Wort + Schatz for the first level", () async {
    databaseInterface.compounds = Compounds.all;
    final poolGenerator = GraphBasedPoolGenerator(databaseInterface);
    final levelProvider = LogarithmicLevelProvider();
    final levelSetup = levelProvider.generateLevelSetup(1);
    final compounds = await poolGenerator.generateFromLevelSetup(levelSetup);
    expect(compounds, [Compounds.Wortschatz]);
  });



  // This is a exploratory test, it does not test a specific behavior
  test(skip: true, "print the generation times for the first 30 levels",
      () async {

    setupTestLocator();
    final poolGenerator = GraphBasedPoolGenerator(
        locator<DatabaseInterface>());
    final levelProvider = BasicLevelProvider();

    for (int level = 1; level < 30; level++) {
      final stopwatch = Stopwatch()..start();
      final levelSetup = levelProvider.generateLevelSetup(level);
      final compounds = await poolGenerator.generateFromLevelSetup(levelSetup);
      print("Level $level: ${stopwatch.elapsedMilliseconds}ms");
    }

    expect(true, true);
  });
}
