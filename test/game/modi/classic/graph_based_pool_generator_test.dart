import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/modi/classic/generator/compound_pool_generator.dart';
import 'package:kompositum/game/modi/classic/generator/graph_based_pool_generator.dart';
import 'package:test/test.dart';

import '../../../mocks/mock_database_initializer.dart';
import '../../../mocks/mock_database_interface.dart';
import '../../../test_data/compounds.dart';
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
    for (int i = 0; i < 10; i++) {
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
    }
  });

  test("should not return duplicates", () async {
    for (int i = 0; i < 10; i++) {
      databaseInterface.compounds = [Compounds.Apfelkuchen, Compounds.Schneemann];
        sut = GraphBasedPoolGenerator(databaseInterface);
        final compounds = await sut.generateRestricted(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 3,
        );
        expect(compounds.length, 2);
      }
  });

  test("Nationalelf: prevent modifier head pairs if they would otherwise be conflicts (considering lowercase)", () async {
    for (int i = 0; i < 10; i++) {
      databaseInterface.compounds = [
        Compound(id: 0, name: "Nationalmannschaft", modifier: "national", head: "Mannschaft", frequencyClass: 1),
        Compound(id: 0, name: "Elfmeter", modifier: "elf", head: "Meter", frequencyClass: 1),
        Compound(id: 0, name: "Nationalelf", modifier: "national", head: "Elf", frequencyClass: 1),
      ];
      sut = GraphBasedPoolGenerator(databaseInterface);
      final compounds = await sut.generate(
        frequencyClass: CompactFrequencyClass.easy,
        compoundCount: 3,
      );
      expect(compounds.length, 1);
    }
  });

  test("edgecase Überflussgesellschaft: should return the compound with umlaut", () async {
    final databaseInitializer = MockDatabaseInitializer([
      Compounds.Apfelbaum,
      Compound(id: 0, name: "Überflussgesellschaft", modifier: "Überfluss", head: "Gesellschaft", frequencyClass: 1),
    ]);
    final objectBoxInterface = DatabaseInterface(databaseInitializer);
    sut = GraphBasedPoolGenerator(objectBoxInterface);
    final compounds = await sut.generate(
      frequencyClass: CompactFrequencyClass.easy,
      compoundCount: 2,
    );
    expect(compounds.length, 2);
    objectBoxInterface.close();
  });
}
