import 'package:kompositum/util/app_version_provider.dart';
import 'package:path/path.dart';

import '../objectbox.g.dart';
import 'compound_origin.dart';
import 'models/compound.dart';

class DatabaseInitializer {
  final CompoundOrigin compoundOrigin;
  final AppVersionProvider appVersionProvider;

  final bool forceReset;
  final String path;

  DatabaseInitializer({
    required this.compoundOrigin,
    required this.appVersionProvider,
    required this.path,
    this.forceReset = false
  });

  Future<Store> getInitializedDatabase() async {
    final store = await openStore(directory: join(path, "compounds"));
    final count = store.box<Compound>().count();

    final reset = forceReset || await appVersionProvider.didAppVersionChange;

    if (count == 0) {
      await _insertCompoundsFromCompoundData(store);
    } else if (reset) {
      final start = DateTime.now();
      print("Resetting database...");
      await _resetDatabase(store);
      final end = DateTime.now();
      final duration = end.difference(start);
      print("Database reset in ${duration.inSeconds} seconds");
    }

    final countAfter = store.box<Compound>().count();
    print("Database initialized with $countAfter compounds");
    return store;
  }

  Future<void> _resetDatabase(Store store) async {
    store.box<Compound>().removeAll();
    await _insertCompoundsFromCompoundData(store);
  }

  Future<void> _insertCompoundsFromCompoundData(Store store) async {
    final count = store.box<Compound>().count();
    assert(count == 0);

    await compoundOrigin.getCompounds().then((compoundData) async {
      store.box<Compound>().putMany(compoundData);
    });
  }
}
