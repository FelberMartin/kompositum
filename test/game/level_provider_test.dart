import 'package:graph_collection/graph.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/game/compact_frequency_class.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/locator.dart';
import 'package:kompositum/util/random_util.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

class TestBasicLevelProvider extends BasicLevelProvider {
  final int i;
  TestBasicLevelProvider(CompoundPoolGenerator compoundPoolGenerator, this.i)
      : super(compoundPoolGenerator);

  @override
  int getSeedForLevel(int level) {
    return level + 1;
  }
}

void main() {

  late LevelProvider sut;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;

    setupLocator();

  });

  /// This test is only here to manually find good seeds for the compounds generation.
  test(skip: true, "find good seeds", () async {
    final poolGenerator = locator<CompoundPoolGenerator>();
    for (int i = 0; i < 10; i++) {
      print("\nSeed addition $i");
      sut = TestBasicLevelProvider(poolGenerator, i);

      for (int level = 1; level < 6; level++) {
        final compounds = await sut.generateCompoundPool(level);
        final compoundNames = compounds.map((compound) => compound.name).toList();
        print("Level $level: $compoundNames");
      }
    }

    expect(true, true);
  });

  /// Findings:
  /// - The chance of having no duplicates at level 6 is only ~30%.
  test(skip: true, "how many duplicates are there within the first 20 levels", () async {
    final poolGenerator = GraphBasedPoolGenerator(locator<DatabaseInterface>());
    sut = BasicLevelProvider(poolGenerator);

    // Print the number of compounds in the easy frequency class
    final databaseInterface = locator<DatabaseInterface>();
    final allCompounds = await databaseInterface.getAllCompounds();
    final easyCompounds = allCompounds.where((compound) => compound.frequencyClass != null && compound.frequencyClass! <= CompactFrequencyClass.easy.maxFrequencyClass!).toList();
    print("Easy compounds: ${easyCompounds.length}");

    final overallCompounds = <String>[];
    for (int level = 1; level < 20; level++) {
      final compounds = await sut.generateCompoundPool(level);
      final compoundNames = compounds.map((compound) => compound.name).toList();
      print("Level $level: $compoundNames");

      final duplicates = compoundNames.where((name) => overallCompounds.contains(name)).toList();
      print("Duplicates: $duplicates");
      overallCompounds.addAll(compoundNames);
    }

    print("Overall compounds: ${overallCompounds.length}");

    // Print an overview of how often each compound occurs
    final compoundCountMap = <String, int>{};
    for (final compound in overallCompounds) {
      compoundCountMap[compound] = (compoundCountMap[compound] ?? 0) + 1;
    }
    // Remove where count is only 1
    compoundCountMap.removeWhere((key, value) => value == 1);
    print("Compound count map: $compoundCountMap");

    expect(true, true);
  });
}