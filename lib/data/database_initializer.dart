import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'compound.dart';
import 'compound_origin.dart';

class DatabaseInitializer {
  final CompoundOrigin compoundOrigin;

  DatabaseInitializer(this.compoundOrigin);

  Future<Database> getInitializedDatabase(
      {bool reset = false, bool useInMemoryDatabase = false}) async {
    String path = await _getPath(useInMemoryDatabase);
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createCompoundsTable(db);
        await _insertCompoundsFromCompoundData(db);
      },
    );

    if (reset) {
      await db.delete("compounds");
      await _insertCompoundsFromCompoundData(db);
    }
    return db;
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

  Future<void> _insertCompoundsFromCompoundData(Database db) async {
    await compoundOrigin.getCompounds().then((compoundData) {
      final batch = db.batch();
      for (final compound in compoundData) {
        batch.insert("compounds", compound.toMap());
      }
      return batch.commit();
    });
  }
}
