import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/util/app_version_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

class MockCompoundOrigin extends Mock implements CompoundOrigin {}

class MockAppVersionProvider extends Mock implements AppVersionProvider {
  bool didAppVersionChange = false;
}

void main() async {
  late CompoundOrigin compoundOrigin;
  late DatabaseInitializer sut;
  final MockAppVersionProvider appVersionProvider = MockAppVersionProvider();

  final compoundsFromOrigin = [Compounds.Krankenhaus];

  // A different list of compounds to test if the database is initialized correctly
  final compoundsFromOrigin2 = [Compounds.Spielplatz, Compounds.Apfelbaum];
  final compoundsFromOrigin3 = [Compounds.Schneemann];

  DatabaseInitializer _createSut({bool reset = true}) {
    return DatabaseInitializer(
      compoundOrigin: compoundOrigin,
      appVersionProvider: appVersionProvider,
      path: "test/data",
      forceReset: reset,
    );
  }

  setUp(() {
    flutter_test.TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

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
        expect(compounds, compoundsFromOrigin);
        database.close();
      },
    );

    test(
      "should reset the current compounds if reset is true ",
      () async {
        sut = _createSut(reset: true);
        final databaseBefore = await sut.getInitializedDatabase();
        final compoundsBefore = databaseBefore.box<Compound>().getAll();
        expect(compoundsBefore, compoundsFromOrigin);

        databaseBefore.close();

        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => compoundsFromOrigin2);
        final database = await sut.getInitializedDatabase();

        final compounds = database.box<Compound>().getAll();
        expect(compounds, compoundsFromOrigin2);
        database.close();
      },
    );

    test("should reset the current compounds if the app version changed", () async {
      sut = _createSut(reset: false);
      final databaseBefore = await sut.getInitializedDatabase();
      final compoundsBefore = databaseBefore.box<Compound>().getAll();
      expect(compoundsBefore, compoundsFromOrigin2);
      databaseBefore.close();

      appVersionProvider.didAppVersionChange = true;

      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => compoundsFromOrigin3);
      sut = _createSut(reset: false);
      final database = await sut.getInitializedDatabase();

      final compounds = database.box<Compound>().getAll();
      expect(compounds, compoundsFromOrigin3);
      database.close();
    });
  });

}
