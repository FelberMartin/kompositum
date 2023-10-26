import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'compound.dart';

class DatabaseHelper {
  static Database? _database;
  static const _tableName = 'compounds';

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final database =
        openDatabase(join(await getDatabasesPath(), 'compounds.db'), version: 1,
            onCreate: (db, version) {
      print('Creating database');
      _createCompoundTable(db);
      _insertCompoundDataFromCsvIntoDatabase(db);
    });
    // delete all the data and insert it again
    await database.then((db) => db.delete(_tableName));
    _insertCompoundDataFromCsvIntoDatabase(await database);
    return database;
  }

  static void _createCompoundTable(Database db) {
    db.execute(
        'CREATE TABLE compounds(name TEXT PRIMARY KEY, modifier TEXT, head TEXT, frequencyClass INTEGER DEFAULT NULL)');
  }

  static void _insertCompoundDataFromCsvIntoDatabase(Database db) {
    rootBundle.loadString('assets/test.csv').then((value) {
      final lines = value.split('\r\n').skip(1);
      for (final line in lines) {
        if (line == '') {
          continue;
        }
        line.trim();
        final columns = line.split(',');
        if (columns.length != 4) {
          throw Exception(
              'Invalid number of columns in line: $line. Expected 4, got ${columns.length}');
        }
        try {
          db.insert(_tableName, {
            'name': columns[0],
            'modifier': columns[1],
            'head': columns[2],
            'frequencyClass': columns[3],
          });
        } catch (e) {
          print('Error while inserting line: $line');
          print(e);
          break;
        }
      }
    });
  }

  static Future<List<Compound>> getAllCompounds() async {
    final db = await database;
    final compounds = await db.rawQuery("SELECT * FROM $_tableName");
    return compounds.map((e) => Compound.fromMap(e)).toList();
  }

  /// Returns a compound (if there is any) that match the given [modifier] and [head].
  static Future<Compound?> getCompound(String modifier, String head) async {
    final db = await database;
    final compounds = await db.query(_tableName,
        where: 'modifier = ? AND head = ?', whereArgs: [modifier, head]);
    if (compounds.isEmpty) {
      return null;
    }
    return Compound.fromMap(compounds.first);
  }

  /// Returns a random compound with a frequency class of [maxFrequencyClass] or lower.
  /// If [maxFrequencyClass] is null, a random compound is returned.
  static Future<Compound?> getRandomCompound(int? maxFrequencyClass) async {
    final db = await database;
    final query = db.query(_tableName,
        orderBy: 'RANDOM()',
        limit: 1,
        where: maxFrequencyClass != null ? 'frequencyClass <= ?' : null,
        whereArgs: maxFrequencyClass != null ? [maxFrequencyClass] : null);
    final compounds = await query;
    if (compounds.isEmpty) {
      return null;
    }

    return Compound.fromMap(compounds.first);
  }

  /// Returns a compound where the modifier or head of that compound match the
  /// given [component]. If there are multiple compounds that match, a random
  /// compound is returned. Furthermore, the frequency class of the compound must
  /// be [maxFrequencyClass] or lower. If [maxFrequencyClass] is null, the frequency
  /// class is ignored.
  static Future<Compound?> getRandomCompoundByComponent({
    required String component,
    int? maxFrequencyClass
  }) async {
    maxFrequencyClass ??= 28;   // Max frequency class is 28
    final db = await database;
    final query = db.query(_tableName,
        orderBy: 'RANDOM()',
        limit: 1,
        where: '(modifier = ? OR head = ?) AND frequencyClass <= ?',
        whereArgs: [component, component, maxFrequencyClass]);
    final compounds = await query;
    if (compounds.isEmpty) {
      return null;
    }
    return Compound.fromMap(compounds.first);
  }


  /// Count the number of compounds in the database using a raw SQL query.
  static Future<int> countCompounds() async {
    final db = await database;
    final query = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(query) ?? 0;
  }

}
