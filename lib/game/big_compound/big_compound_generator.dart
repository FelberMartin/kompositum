import 'dart:collection';
import 'dart:math';

import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/util/random_util.dart';

import '../../data/compound_origin.dart';
import '../../data/models/compact_frequency_class.dart';
import '../../data/models/compound.dart';
import 'component_tree.dart';


class BigCompoundGenerator {
  final DatabaseInterface databaseInterface;

  BigCompoundGenerator(this.databaseInterface);

  Future<ComponentForest> generate({
    int count = 2,
    int? seed,
  }) async {
    final possibleCompoundStrings = await _readPossibleBigCompounds();
    final chosenCompoundStrings = randomSampleWithoutReplacement(possibleCompoundStrings, count);

    return ComponentForest.generate(
      databaseInterface: databaseInterface,
      rootStrings: chosenCompoundStrings,
    );
  }

  /// Read the compounds from the assets/compounds_with_level.csv file
  Future<List<String>> _readPossibleBigCompounds() async {
    final compoundOrigin = CompoundOrigin("assets/compounds_with_level.csv");
    final compounds = await compoundOrigin.getCompounds();
    return compounds.map((compound) => compound.name).toList();
  }
}
