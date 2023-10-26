import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const _tableName = 'compounds';

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'compounds.db'),
      version: 1,
      onCreate: (db, version) {
        createCompoundTable(db);
        insertCompoundDataFromCsvIntoDatabase(db);
    });
    return database;
  }

  static void createCompoundTable(Database db) {
    db.execute(
        'CREATE TABLE compounds(name TEXT PRIMARY KEY, modifier TEXT, head TEXT, frequencyClass INTEGER DEFAULT NULL)');
  }

  static void insertCompoundDataFromCsvIntoDatabase(Database db) {
    rootBundle.loadString('assets/filtered_compounds.csv').then((value) {
      final lines = value.split('\n');
      for (final line in lines) {
        final columns = line.split(',');
        if (columns.length < 3 || columns.length > 4) {
          throw Exception(
              'Invalid number of columns in line: $line. Expected 3 or 4, got ${columns.length}');
        }
        final frequencyClass = columns.length == 4 ? columns[3] : null;
        db.insert(_tableName, {
          'name': columns[0],
          'modifier': columns[1],
          'head': columns[2],
          'frequencyClass': frequencyClass,
        });
      }
    });
  }


}
