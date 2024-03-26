import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:mocktail/mocktail.dart';

class MockKeyValueStore extends Mock implements KeyValueStore {
  final _blockedCompounds = <Compound>[];

  @override
  Future<List<Compound>> getBlockedCompounds(
      Future<Compound?> Function(String) nameToCompound) {
    return Future.value(_blockedCompounds);
  }

  @override
  Future<void> storeBlockedCompounds(List<Compound> compounds) {
    _blockedCompounds.clear();
    _blockedCompounds.addAll(compounds);
    return Future.value();
  }
}