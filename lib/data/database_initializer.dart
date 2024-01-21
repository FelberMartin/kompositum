import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path_provider/path_provider.dart';
import '../objectbox.g.dart';
import 'compound_origin.dart';
import 'models/compound.dart';

class DatabaseInitializer {
  final CompoundOrigin compoundOrigin;
  final bool useInMemoryDatabase;
  final bool reset;

  DatabaseInitializer(this.compoundOrigin,
      {this.useInMemoryDatabase = false, this.reset = false});



  Future<Store> getInitializedDatabase() async {
    final docsDir = await getApplicationDocumentsDirectory();

    final store = await openStore(directory: join(docsDir.path, "obx-example"));

    // String path = await _getPath(useInMemoryDatabase);
    // final db = await openDatabase(
    //   path,
    //   version: 1,
    //   onCreate: (db, version) async {
    //     await _createCompoundsTable(db);
    //     await _insertCompoundsFromCompoundData(db);
    //     print("Database created");
    //   },
    // );

    if (reset) {
      final start = DateTime.now();
      print("Resetting database...");
      await _resetDatabase(store);
      final end = DateTime.now();
      final duration = end.difference(start);
      print("Database reset in ${duration.inSeconds} seconds");
    }

    final count = store.box<Compound>().count();
    print("Database initialized with $count compounds");
    return store;
  }

  Future<void> _resetDatabase(Store store) async {
    await store.box<Compound>().removeAll();
    await _insertCompoundsFromCompoundData(store);
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

  Future<void> _insertCompoundsFromCompoundData(Store store, {batchSize = 100}) async {
    final count = store.box<Compound>().count();
    assert(count == 0);

    await compoundOrigin.getCompounds().then((compoundData) async {
      store.box<Compound>().putMany(compoundData);
    });
  }
}
