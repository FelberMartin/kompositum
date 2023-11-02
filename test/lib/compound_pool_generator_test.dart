import 'package:kompositum/compound_pool_generator.dart';
import 'package:kompositum/data/compound.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

class MockDatabaseInterface extends Mock implements DatabaseInterface {
  var compounds = <Compound>[];

  @override
  Future<List<Compound>> getAllCompounds() {
    return Future.value(compounds);
  }

  @override
  Future<Compound?> getRandomCompoundRestricted(
      {required int? maxFrequencyClass,
      List<String> forbiddenComponents = const []}) {
    var possibleCompounds = compounds;
    if (maxFrequencyClass != null) {
      possibleCompounds = possibleCompounds
          .where((compound) =>
              compound.frequencyClass != null &&
              compound.frequencyClass! <= maxFrequencyClass)
          .toList();
    }

    if (forbiddenComponents.isNotEmpty) {
      possibleCompounds = possibleCompounds
          .where((compound) =>
              !forbiddenComponents.contains(compound.modifier) &&
              !forbiddenComponents.contains(compound.head))
          .toList();
    }
    return Future.value(possibleCompounds.isNotEmpty
        ? possibleCompounds.first
        : null);
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
            Compounds.Apfelkuchen.withCompactFrequencyClass(CompactFrequencyClass.medium),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.hard),
          ];
          expect(sut.generate(
            frequencyClass: CompactFrequencyClass.easy,
            compoundCount: 2,
          ), throwsException);
        },
      );

      test(
        "should return the given number of compounds",
        () async {
          databaseInterface.compounds = [
            Compounds.Krankenhaus.withCompactFrequencyClass(CompactFrequencyClass.easy),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.easy),
          ];
          final compounds = await sut.generate(
            frequencyClass: CompactFrequencyClass.easy,
            compoundCount: 2,
          );
          expect(compounds.length, 2);
        },
      );

      test(
        "should return a shorter list if the wanted number of compounds would result in clashes",
        () async {
          databaseInterface.compounds = [
            Compounds.Apfelkuchen.withCompactFrequencyClass(CompactFrequencyClass.easy),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.easy),
            Compounds.Krankenhaus.withCompactFrequencyClass(CompactFrequencyClass.easy),
          ];
          final compounds = await sut.generate(
            frequencyClass: CompactFrequencyClass.easy,
            compoundCount: 3,
          );
          expect(compounds.length, 2);
        },
      );

      test(
        "should return also compounds with frequency classes lower than the given one",
        () async {
          databaseInterface.compounds = [
            Compounds.Krankenhaus.withCompactFrequencyClass(CompactFrequencyClass.easy),
            Compounds.Apfelbaum.withCompactFrequencyClass(CompactFrequencyClass.medium),
            Compounds.Schneemann.withCompactFrequencyClass(CompactFrequencyClass.hard),
          ];
          final compounds = await sut.generate(
            frequencyClass: CompactFrequencyClass.hard,
            compoundCount: 3,
          );
          expect(compounds.length, 3);
        },
      );

    });
}
