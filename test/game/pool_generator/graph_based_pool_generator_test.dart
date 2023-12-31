import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:test/test.dart';

import '../../data/mock_database_interface.dart';
import '../../test_data/compounds.dart';
import 'compound_pool_generator_test.dart';

void main() {
  final databaseInterface = MockDatabaseInterface();
  late CompoundPoolGenerator sut;

  runGeneralPoolGeneratorTests((
    databaseInterface,
    {
      int blockLastN = 50
    }) =>
      GraphBasedPoolGenerator(
          databaseInterface,
          blockLastN: blockLastN
      )
  );

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

  test("should not return duplicates", () async {
    databaseInterface.compounds = [Compounds.Apfelkuchen, Compounds.Schneemann];
    sut = GraphBasedPoolGenerator(databaseInterface);
    final compounds = await sut.generateRestricted(
      frequencyClass: CompactFrequencyClass.easy,
      compoundCount: 3,
    );
    expect(compounds.length, 2);
  });
}
