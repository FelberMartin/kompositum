import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

class MockCompoundOrigin extends Mock implements CompoundOrigin {}

void main() async {
  late CompoundOrigin compoundOrigin;
  late DatabaseInitializer sut;

  final compoundsFromOrigin = [Compounds.Krankenhaus];

  // A different list of compounds to test if the database is initialized correctly
  final compoundsFromOrigin2 = [Compounds.Spielplatz, Compounds.Apfelbaum];


  DatabaseInitializer _createSut({bool reset = true}) {
    return DatabaseInitializer(
      compoundOrigin: compoundOrigin,
      path: "test/data",
      reset: reset,
    );
  }

  setUp(() {
    flutter_test.TestWidgetsFlutterBinding.ensureInitialized();

    compoundOrigin = MockCompoundOrigin();
    when(() => compoundOrigin.getCompounds())
        .thenAnswer((_) async => compoundsFromOrigin);
    sut = _createSut();
  });

  group("getInitializedDatabase", () {
    test(
      "should return a database",
      () async {
        final database = await sut.getInitializedDatabase();
        expect(database, isNotNull);
        database.close();
      },
    );

    test(
      "should return a database with the compounds from the origin",
      () async {
        final database = await sut.getInitializedDatabase();

        final compounds = database.box<Compound>().getAll();
        expect(compounds, isNotEmpty);
        expect(compounds, compoundsFromOrigin);
        database.close();
      },
    );
  });

  group("getInitializedDatabase with reset", () {
    test(
      "should leave the current compounds if reset is false ",
      () async {
        sut = _createSut(reset: false);
        final databaseBefore = await sut.getInitializedDatabase();
        databaseBefore.close();

        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => compoundsFromOrigin2);
        final database = await sut.getInitializedDatabase();

        final compounds = database.box<Compound>().getAll();
        expect(compounds, isNotEmpty);
        expect(compounds, compoundsFromOrigin);
        database.close();
      },
    );

    test(
      "should reset the current compounds if reset is true ",
      () async {
        sut = _createSut(reset: true);
        final databaseBefore = await sut.getInitializedDatabase();
        databaseBefore.close();

        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => compoundsFromOrigin2);
        final database = await sut.getInitializedDatabase();

        final compounds = database.box<Compound>().getAll();
        expect(compounds, isNotEmpty);
        expect(compounds, compoundsFromOrigin2);
        database.close();
      },
    );
  });

}
