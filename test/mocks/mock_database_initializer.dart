import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/objectbox.g.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';

class MockDatabaseInitializer extends Mock implements DatabaseInitializer {

  final List<Compound> compounds;

  MockDatabaseInitializer(this.compounds);

  @override
  Future<Store> getInitializedDatabase() async {
    final store = await openStore(directory: join("test/test_data", "compounds"));
    store.box<Compound>().putMany(compounds);
    return store;
  }

}