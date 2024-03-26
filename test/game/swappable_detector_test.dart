import 'package:kompositum/game/swappable_detector.dart';
import 'package:test/test.dart';

import '../mocks/mock_database_interface.dart';
import '../test_data/compounds.dart';

void main() {
  final databaseInterface = MockDatabaseInterface();
  late SwappableDetector sut;

  setUp(() {
    sut = SwappableDetector(databaseInterface);
  });

  group("getSwappables", () {
    test("returns empty list if no swappables exist", () async {
      databaseInterface.compounds = [Compounds.Apfelbaum, Compounds.Schneemann];
      final swappables = await sut.getSwappables(Compounds.all);
      expect(swappables, isEmpty);
    });

    test("returns swappable if one exists", () async {
      databaseInterface.compounds = [Compounds.Baumaschine, Compounds.Maschinenbau];
      final swappables = await sut.getSwappables([Compounds.Maschinenbau]);
      expect(swappables, hasLength(1));
      expect(swappables.first.original, Compounds.Maschinenbau);
      expect(swappables.first.swapped, Compounds.Baumaschine);
    });
  });
}