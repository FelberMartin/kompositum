import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:kompositum/data/database_initializer.dart';
import 'package:sqflite/sqflite.dart';

import 'models/compact_frequency_class.dart';
import '../util/random_util.dart';
import 'models/compound.dart';

class DatabaseInterface {
  final DatabaseInitializer databaseInitializer;
  late final Future<Database> _database;

  DatabaseInterface(this.databaseInitializer) {
    _database = databaseInitializer.getInitializedDatabase();
  }

  /// Get the number of compounds stored in the database
  Future<int> getCompoundCount() async {
    final db = await _database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM compounds'))!;
  }

  /// Get all the compounds stored in the database
  Future<List<Compound>> getAllCompounds() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query('compounds');
    return maps.map((map) => Compound.fromMap(map)).toList();
  }

  /// Get all the compound within the given compact frequency class.
  Future<List<Compound>> getCompoundsByCompactFrequencyClass(
      CompactFrequencyClass frequencyClass) async {
    return getCompoundsByFrequencyClass(frequencyClass.maxFrequencyClass);
  }

  /// Get all compounds within the given frequency class. If [frequencyClass]
  /// is null, all compounds are returned.
  Future<List<Compound>> getCompoundsByFrequencyClass(
      int? frequencyClass) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'compounds',
      where: frequencyClass == null ? null : 'frequencyClass <= ?',
      whereArgs: frequencyClass == null ? null : [frequencyClass],
    );
    return maps.map((map) => Compound.fromMap(map)).toList();
  }

  /// Get a compound with the given modifier and head. The modifier and
  /// head are not case sensitive.
  /// If no compound with the given modifier and head exists, null is returned.
  Future<Compound?> getCompoundCaseInsensitive(String modifier, String head) async {
    final db = await _database;
    List<Map<String, dynamic>> maps;

    const edgeCases = ["ä", "Ä", "ö", "Ö", "ü", "Ü", "ß"];
    if (modifier.characters.any((char) => edgeCases.contains(char)) ||
        head.characters.any((char) => edgeCases.contains(char))) {
      maps = await db.query(
      'compounds',
      where: 'modifier = ? AND head = ?',
      whereArgs: [modifier, head],
      );
    } else {
      maps = await db.query(
      'compounds',
      where: 'LOWER(modifier) = ? AND LOWER(head) = ?',
      whereArgs: [modifier.toLowerCase(), head.toLowerCase()],
      );
    }

    if (maps.isEmpty) {
      return null;
    }
    return Compound.fromMap(maps.first);
  }

  /// Get a compound with the given modifier and head.
  /// If no compound with the given modifier and head exists, null is returned.
  Future<Compound?> getCompound(String modifier, String head) async {
    final db = await _database;
    final maps = await db.query(
      'compounds',
      where: 'modifier = ? AND head = ?',
      whereArgs: [modifier, head],
    );

    if (maps.isEmpty) {
      return null;
    }
    return Compound.fromMap(maps.first);
  }

  /// Get the compound with the given name. If no compound with the given name
  /// exists, null is returned.
  Future<Compound?> getCompoundByName(String name) async {
    final db = await _database;
    final maps = await db.query(
      'compounds',
      where: 'name = ?',
      whereArgs: [name],
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
    required int? maxFrequencyClass,
    List<String> forbiddenComponents = const [],
  }) async {
    final db = await _database;

    // Query setup
    var whereCondition =
        'UPPER(modifier) NOT IN (${forbiddenComponents.map((_) => '?').join(',')}) '
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

  /// Get a random compound with a frequency class lower or equal to the given
  /// frequency class. If [maxFrequencyClass] is null, the frequency class is
  /// not restricted.
  /// If fewer compounds than [count] match the given restrictions, a smaller
  /// number of compounds is returned.
  Future<List<Compound>> getRandomCompounds(
      {required int count, required int? maxFrequencyClass, int? seed}) async {
    final db = await _database;
    final random = Random(seed);
    var compoundDataMaps = <Map<String, dynamic>>[];
    if (maxFrequencyClass == null) {
      compoundDataMaps = await db.query('compounds');
    } else {
      compoundDataMaps = await db.query(
        'compounds',
        where: 'frequencyClass <= ?',
        whereArgs: [maxFrequencyClass],
      );
    }

    final sample = randomSampleWithoutReplacement(
        compoundDataMaps, min(count, compoundDataMaps.length), random: random);
    return sample.map((map) => Compound.fromMap(map)).toList();
  }
}
