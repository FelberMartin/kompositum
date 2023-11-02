import 'package:kompositum/data/database_initializer.dart';
import 'package:sqflite/sqflite.dart';

import 'compound.dart';

class DatabaseInterface {
  final DatabaseInitializer databaseInitializer;
  late final Future<Database> _database;

  DatabaseInterface(this.databaseInitializer) {
    _database = databaseInitializer.getInitializedDatabase();
  }

  /// Get all the compounds stored in the database
  Future<List<Compound>> getAllCompounds() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('compounds');
    return maps.map((map) => Compound.fromMap(map)).toList();
  }

  /// Get a compound with the given modifier and head. The modifier and
  /// head are not case sensitive.
  /// If no compound with the given modifier and head exists, null is returned.
  Future<Compound?> getCompound(String modifier, String head) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'compounds',
      where: 'UPPER(modifier) = ? AND UPPER(head) = ?',
      whereArgs: [modifier.toUpperCase(), head.toUpperCase()],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Compound.fromMap(maps.first);
  }

  /// Get a random compound with a frequency class lower or equal to the given
  /// frequency class. Additionally, the compound must not contain any of the
  /// given forbidden components in the head or modifier. These [forbiddenComponents]
  /// are not case sensitive.
  /// If [maxFrequencyClass] is null, the frequency class is not restricted.
  /// If no compound with the given restrictions exists, null is returned.
  Future<Compound?> getRandomCompoundRestricted({
    required int? maxFrequencyClass, List<String> forbiddenComponents = const [],
  }) async {
   final db = await _database;

   // Query setup
   var whereCondition = 'UPPER(modifier) NOT IN (${forbiddenComponents.map((_) => '?').join(',')}) '
       'AND UPPER(head) NOT IN (${forbiddenComponents.map((_) => '?').join(',')})';
    var whereArgs = [
        ...forbiddenComponents.map((component) => component.toUpperCase()),
        ...forbiddenComponents.map((component) => component.toUpperCase())
      ];
    if (maxFrequencyClass != null) {
      whereCondition += ' AND frequencyClass <= ?';
      whereArgs.add(maxFrequencyClass.toString());
    }

    // Execute query
    final List<Map<String, dynamic>> maps = await db.query(
      'compounds',
      orderBy: 'RANDOM()',
      limit: 1,
      where: whereCondition,
      whereArgs: whereArgs,
    );

    // Process query result
    if (maps.isEmpty) {
      return null;
    }
    return Compound.fromMap(maps.first);
  }

  
}