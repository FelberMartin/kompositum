import 'package:kompositum/config/locator.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/game/level_setup_provider.dart';
import 'package:kompositum/game/modi/classic/classic_level_setup_provider.dart';
import 'package:kompositum/game/modi/classic/generator/graph_based_classic_level_content_generator.dart';
import 'package:test/test.dart';


void main() {

  late LevelSetupProvider sut;


  /// Findings:
  /// - The chance of having no duplicates at level 6 is only ~30%.
  test(skip: true, "how many duplicates are there within the first 20 levels", () async {
    final poolGenerator = GraphBasedClassicLevelContentGenerator(locator<DatabaseInterface>());
    sut = LogarithmicLevelSetupProvider();

    // Print the number of compounds in the easy frequency class
    final databaseInterface = locator<DatabaseInterface>();
    final allCompounds = await databaseInterface.getAllCompounds();
    final easyCompounds = allCompounds.where((compound) => compound.frequencyClass != null && compound.frequencyClass! <= CompactFrequencyClass.easy.maxFrequencyClass!).toList();
    print("Easy compounds: ${easyCompounds.length}");

    final overallCompounds = <String>[];
    for (int level = 1; level < 20; level++) {
      final levelSetup = sut.generateLevelSetup(level);
      final content = await poolGenerator.generateFromLevelSetup(levelSetup);
      final compoundNames = content.getCompounds().map((compound) => compound.name).toList();
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