import 'dart:async';

import 'package:kompositum/data/database_initializer.dart';

import '../objectbox.g.dart';
import 'models/compact_frequency_class.dart';
import 'models/compound.dart';

class DatabaseInterface {
  final DatabaseInitializer databaseInitializer;
  late final Future<Store> _database;

  DatabaseInterface(this.databaseInitializer) {
    _database = databaseInitializer.getInitializedDatabase();
  }

  Future<void> waitForInitialization() async {
    await _database;
  }

  Future<void> close() async {
    final db = await _database;
    db.close();
  }

  /// Get the number of compounds stored in the database
  Future<int> getCompoundCount() async {
    final db = await _database;
    return db.box<Compound>().count();
  }

  /// Get all the compounds stored in the database
  Future<List<Compound>> getAllCompounds() async {
    final db = await _database;
    return db.box<Compound>().getAll();
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
    final query = db.box<Compound>().query(
        Compound_.frequencyClass.lessOrEqual(frequencyClass ?? 28)).build();
    return query.find();
  }

  /// Get a compound with the given modifier and head.
  /// If no compound with the given modifier and head exists, null is returned.
  /// Note: The objectbox caseSensitivity only works for ASCII characters, so
  /// not for the German umlauts.
  Future<Compound?> getCompound(String modifier, String head, {bool caseSensitive = true}) async {
    final db = await _database;
    final query = db.box<Compound>().query(
        Compound_.modifier.equals(modifier, caseSensitive: caseSensitive) &
        Compound_.head.equals(head, caseSensitive: caseSensitive)
    ).order(
        Compound_.frequencyClass, flags: Order.nullsLast
    ).build();
    return query.findFirst();
  }

  /// Get the compound with the given name. If no compound with the given name
  /// exists, null is returned.
  /// If there are multiple compounds with the same name, return the one with
  /// the more frequent frequency class.
  Future<Compound?> getCompoundByName(String name) async {
    final db = await _database;
    final query = db.box<Compound>().query(
        Compound_.name.equals(name)
    ).order(
        Compound_.frequencyClass, flags: Order.nullsLast
    ).build();
    return query.findFirst();
  }
}
