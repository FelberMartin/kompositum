import 'package:kompositum/config/locator.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/modi/pool/generator/graph_based_pool_generator.dart';
import 'package:kompositum/game/modi/pool/pool_level_provider.dart';
import 'package:test/test.dart';


void main() {

  late LevelProvider sut;


  /// Findings:
  /// - The chance of having no duplicates at level 6 is only ~30%.
  test(skip: true, "how many duplicates are there within the first 20 levels", () async {
    final poolGenerator = GraphBasedPoolGenerator(locator<DatabaseInterface>());
    sut = LogarithmicLevelProvider();

    // Print the number of compounds in the easy frequency class
    final databaseInterface = locator<DatabaseInterface>();
    final allCompounds = await databaseInterface.getAllCompounds();
    final easyCompounds = allCompounds.where((compound) => compound.frequencyClass != null && compound.frequencyClass! <= CompactFrequencyClass.easy.maxFrequencyClass!).toList();
    print("Easy compounds: ${easyCompounds.length}");

    final overallCompounds = <String>[];
    for (int level = 1; level < 20; level++) {
      final levelSetup = sut.generateLevelSetup(level);
      final compounds = await poolGenerator.generateFromLevelSetup(levelSetup);
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