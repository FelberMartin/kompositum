import 'package:kompositum/game/compact_frequency_class.dart';
import 'package:kompositum/game/pool_generator/compound_pool_generator.dart';
import 'package:kompositum/game/pool_generator/graph_based_pool_generator.dart';
import 'package:test/test.dart';

import '../../data/mock_database_interface.dart';
import '../../test_data/compounds.dart';

void main() {
    late CompoundPoolGenerator sut;
    late MockDatabaseInterface databaseInterface = MockDatabaseInterface();

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

}