import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/compound_origin.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

import '../test_data/compounds.dart';

class MockCompoundOrigin extends Mock implements CompoundOrigin {}

void main() async {
  late CompoundOrigin compoundOrigin;
  late DatabaseInitializer sut;

  final compoundsFromOrigin = [Compounds.Krankenhaus];

  // A different list of compounds to test if the database is initialized correctly
  final compoundsFromOrigin2 = [Compounds.Spielplatz, Compounds.Apfelbaum];

  // Setup sqflite_common_ffi for flutter test
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    compoundOrigin = MockCompoundOrigin();
    when(() => compoundOrigin.getCompounds())
        .thenAnswer((_) async => compoundsFromOrigin);
    sut = DatabaseInitializer(compoundOrigin, useInMemoryDatabase: true);
  });

  /// For testing the ffi test framework
  test('Simple test', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, version) async {
      await db
          .execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, value TEXT)');
    });
    // Insert some data
    await db.insert('Test', {'value': 'my_value'});
    // Check content
    expect(await db.query('Test'), [
      {'id': 1, 'value': 'my_value'}
    ]);

    await db.close();
  });

  group("getInitializedDatabase", () {
    test(
      "should return a database",
      () async {
        final database = await sut.getInitializedDatabase();
        expect(database, isNotNull);
      },
    );

    test(
      "should return a database with the compounds table",
      () async {
        final database = await sut.getInitializedDatabase();
        final tables =
            await database.query("sqlite_master", where: "type = 'table'");
        expect(tables, isNotEmpty);
        expect(tables.first["name"], "compounds");
      },
    );

    test(
      "should return a database with the compounds from the origin",
      () async {
        final database = await sut.getInitializedDatabase();

        final compounds = await database.query("compounds");
        expect(compounds, isNotEmpty);
        expect(compounds, compoundsFromOrigin.map((e) => e.toMap()));
      },
    );
  });

  group("getInitializedDatabase with reset", () {
    test(
      "should leave the current compounds if reset is false ",
      () async {
        sut = DatabaseInitializer(compoundOrigin,
            useInMemoryDatabase: true, reset: false);
        await sut.getInitializedDatabase();
        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => compoundsFromOrigin2);
        final database = await sut.getInitializedDatabase();

        final compounds = await database.query("compounds");
        expect(compounds, isNotEmpty);
        expect(compounds, compoundsFromOrigin.map((e) => e.toMap()));
      },
    );

    test(
      "should reset the current compounds if reset is true ",
      () async {
        sut = DatabaseInitializer(compoundOrigin,
            useInMemoryDatabase: true, reset: true);
        await sut.getInitializedDatabase();
        when(() => compoundOrigin.getCompounds())
            .thenAnswer((_) async => compoundsFromOrigin2);
        final database = await sut.getInitializedDatabase();

        final compounds = await database.query("compounds");
        expect(compounds, isNotEmpty);
        expect(compounds, compoundsFromOrigin2.map((e) => e.toMap()));
      },
    );
  });

}
