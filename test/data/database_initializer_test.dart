import 'package:kompositum/data/compound.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() async {
  final sut = DatabaseInitializer();

  // Setup sqflite_common_ffi for flutter test
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
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
      "should return a database" ,
      () async {
        final database = await sut.getInitializedDatabase();
        expect(database, isNotNull);
      },
    );

    test(
      "should return a database with the compounds table" ,
          () async {
        final database = await sut.getInitializedDatabase();
        final tables = await database.query("sqlite_master", where: "type = 'table'");
        expect(tables, isNotEmpty);
        expect(tables.first["name"], "compounds");
      },
    );
  });

  group("insertCompounds", () {
      test(
        "should insert the given compounds into the database",
        () async {
          final database = await openDatabase(inMemoryDatabasePath);
          final compounds = [
            const Compound(
              name: "Krankenhaus",
              modifier: "krank",
              head: "Haus",
              frequencyClass: 1,
            ),
          ];
          await sut.insertCompounds(database, compounds);
          final result = await database.query("compounds");
          expect(result, isNotEmpty);
          expect(result.length, 1);
          expect(result.first["name"], "Krankenhaus");
          expect(result.first["modifier"], "krank");
          expect(result.first["head"], "Haus");
          expect(result.first["frequencyClass"], 1);
        },
      );


    });

}