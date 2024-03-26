import 'package:collection/collection.dart'; // You have to add this manually, for some reason it cannot be added automatically
import 'package:kompositum/data/database_initializer.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compact_frequency_class.dart';
import 'package:kompositum/data/models/compound.dart';


class MockDatabaseInterface implements DatabaseInterface {
  var compounds = <Compound>[];

  @override
  Future<int> getCompoundCount() {
    return Future.value(compounds.length);
  }

  @override
  Future<List<Compound>> getCompoundsByFrequencyClass(
      int? frequencyClass) {
    if (frequencyClass == null) {
      return Future.value(compounds);
    }
    return Future.value(compounds
        .where((compound) => compound.frequencyClass != null && compound.frequencyClass! <= frequencyClass)
        .toList());
  }

  @override
  Future<List<Compound>> getAllCompounds() {
    return Future.value(compounds);
  }

  @override
  Future<List<Compound>> getCompoundsByCompactFrequencyClass(
      CompactFrequencyClass frequencyClass) {
    if (frequencyClass.maxFrequencyClass == null) {
      return Future.value(compounds);
    }
    return Future.value(compounds
        .where((compound) =>
    compound.frequencyClass != null &&
        compound.frequencyClass! <= frequencyClass.maxFrequencyClass!)
        .toList());
  }

  @override
  // TODO: implement databaseInitializer
  DatabaseInitializer get databaseInitializer => throw UnimplementedError();

  @override
  Future<Compound?> getCompound(String modifier, String head, {bool caseSensitive = true}) {
    if (caseSensitive) {
      return Future.value(compounds.firstWhereOrNull((compound) =>
      compound.modifier == modifier && compound.head == head));
    }
    return Future.value(compounds.firstWhereOrNull((compound) =>
    compound.modifier.toLowerCase() == modifier.toLowerCase() &&
        compound.head.toLowerCase() == head.toLowerCase()));
  }

  @override
  Future<Compound?> getCompoundByName(String name) {
    return Future.value(compounds.firstWhereOrNull((compound) =>
    compound.name == name));
  }

  @override
  Future<void> close() async {
    // NOOP
  }

  @override
  Future<void> waitForInitialization() {
    return Future.value();
  }

}