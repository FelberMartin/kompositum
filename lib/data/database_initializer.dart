import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'compound.dart';
import 'compound_origin.dart';

class DatabaseInitializer {
  final CompoundOrigin compoundOrigin;
  final bool useInMemoryDatabase;
  final bool reset;

  DatabaseInitializer(this.compoundOrigin,
      {this.useInMemoryDatabase = false, this.reset = false});

  Future<Database> getInitializedDatabase() async {
    String path = await _getPath(useInMemoryDatabase);
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createCompoundsTable(db);
        await _insertCompoundsFromCompoundData(db);
        print("Database created");
      },
    );

    if (reset) {
      await _resetDatabase(db);
    }

    final count = await db.query("compounds").then((value) => value.length);
    print("Database initialized with $count compounds");
    return db;
  }

  Future<void> _resetDatabase(Database db) async {
    await db.delete("compounds");
    await _insertCompoundsFromCompoundData(db);
  }

  Future<String> _getPath(bool useInMemoryDatabase) async {
    String path;
    if (useInMemoryDatabase) {
      path = inMemoryDatabasePath;
    } else {
      WidgetsFlutterBinding.ensureInitialized();
      final dbPath = await getDatabasesPath();
      path = join(dbPath, "kompositum.db");
    }
    return path;
  }

  Future<void> _createCompoundsTable(Database db) {
    return db.execute(
      "CREATE TABLE compounds ("
      "name TEXT PRIMARY KEY,"
      "modifier TEXT,"
      "head TEXT,"
      "frequencyClass INTEGER"
      ")",
    );
  }

  /// The default batch size of 100 was found empirically to be the fastest
  Future<void> _insertCompoundsFromCompoundData(Database db, {batchSize = 100}) async {
    final count = await db.query("compounds").then((value) => value.length);
    assert(count == 0);

    await compoundOrigin.getCompounds().then((compoundData) async {
      var batch = db.batch();
      for (final (index, compound) in compoundData.indexed) {
        batch.insert("compounds", compound.toMap());
        if (index % batchSize == 0) {
          await batch.commit();
          batch = db.batch();
          // print("Inserted $index compounds");
        }
      }
      return batch.commit();
    });
  }
}
