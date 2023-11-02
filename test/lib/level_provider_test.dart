import 'package:kompositum/compound_pool_generator.dart';
import 'package:kompositum/level_provider.dart';
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
}