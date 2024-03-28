import 'package:flutter_test/flutter_test.dart' as flutter_test;
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../mocks/mock_apper_version_provider.dart';
import '../mocks/mock_compound_origin.dart';
import '../test_data/compounds.dart';


void main() async {
  late CompoundOrigin compoundOrigin;
  late DatabaseInitializer sut;
  final MockAppVersionProvider appVersionProvider = MockAppVersionProvider();

  final compoundsFromOrigin = [Compounds.Krankenhaus];
  final compoundsFromOrigin2 = [Compounds.Spielplatz, Compounds.Apfelbaum];

  DatabaseInitializer _createSut({bool reset = true}) {
    return DatabaseInitializer(
      compoundOrigin: compoundOrigin,
      appVersionProvider: appVersionProvider,
      path: "test/test_data",
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

    test("should store multiple compounds with the same name", () async {
      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => [Compounds.Krankenhaus, Compounds.Krankenhaus_v2]);
      sut = _createSut();
      final database = await sut.getInitializedDatabase();

      final compounds = database.box<Compound>().getAll();
      expect(compounds, hasLength(2));
      expect(compounds, [Compounds.Krankenhaus, Compounds.Krankenhaus_v2]);
      database.close();
    });
  });

  group("getInitializedDatabase with reset", () {
    test(
      "should leave the current compounds if reset is false ",
      () async {
        final databaseBefore = await sut.getInitializedDatabase();
        final compoundsBefore = databaseBefore.box<Compound>().getAll();
        databaseBefore.close();

        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => compoundsFromOrigin2);
        sut = _createSut(reset: false);
        final database = await sut.getInitializedDatabase();

        final compounds = database.box<Compound>().getAll();
        expect(compounds, compoundsBefore);
        database.close();
      },
    );

    test(
      "should reset the current compounds if reset is true ",
      () async {
        final databaseBefore = await sut.getInitializedDatabase();
        final compoundsBefore = databaseBefore.box<Compound>().getAll();
        expect(compoundsBefore, compoundsFromOrigin);

        databaseBefore.close();

        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => compoundsFromOrigin2);
        final database = await sut.getInitializedDatabase();

        final compounds = database.box<Compound>().getAll();
        expect(compounds, isNot(compoundsBefore));
        expect(compounds, compoundsFromOrigin2);
        database.close();
      },
    );

    test("should reset the current compounds if the app version changed", () async {
      final databaseBefore = await sut.getInitializedDatabase();
      final compoundsBefore = databaseBefore.box<Compound>().getAll();
      expect(compoundsBefore, compoundsFromOrigin);
      databaseBefore.close();

      appVersionProvider.didAppVersionChange = Future.value(true);

      when(() => compoundOrigin.getCompounds())
          .thenAnswer((_) async => [Compounds.Schneemann]);
      sut = _createSut(reset: false);
      final database = await sut.getInitializedDatabase();

      final compounds = database.box<Compound>().getAll();
      expect(compounds, isNot(compoundsBefore));
      expect(compounds, [Compounds.Schneemann]);
      database.close();
    });
  });

}
