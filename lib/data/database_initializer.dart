import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'compound.dart';

class DatabaseInitializer {
  Future<Database> getInitializedDatabase() {
    WidgetsFlutterBinding.ensureInitialized();
    return getDatabasesPath().then((dbPath) {
      final path = join(dbPath, "kompositum.db");
      return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await createCompoundsTable(db);
          await importCompoundsFromCsv(db, "assets/compounds.csv");
        },
      );
    });
  }

  Future<void> createCompoundsTable(Database db) {
    return db.execute(
      "CREATE TABLE compounds ("
      "name TEXT PRIMARY KEY,"
      "modifier TEXT,"
      "head TEXT,"
      "frequencyClass INTEGER"
      ")",
    );
  }

  Future<void> importCompoundsFromCsv(Database db, String csvFilePath) {
    // return rootBundle.loadString(csvFilePath).then((csv) {
    //   final lines = csv.split("\n");
    //   final compounds = lines.map((line) => Compound.fromCsvLine(line));
    //   return db.transaction((txn) {
    //     compounds.forEach((compound) {
    //       txn.insert("compounds", compound.toMap());
    //     });
    //   });
    // });
    return Future.value();
  }
}
