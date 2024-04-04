import 'dart:collection';
import 'dart:math';

import 'package:kompositum/data/database_interface.dart';

import '../../data/models/compact_frequency_class.dart';
import '../../data/models/compound.dart';
import '../data/compound_origin.dart';


class CompoundTree {
  final CompoundTreeNode root;

  CompoundTree(this.root);

  static Future<CompoundTree> generate({
    required DatabaseInterface databaseInterface,
    required String rootString,
  }) async {
    final rootCompound = await databaseInterface.getCompoundByName(rootString);
    final tree = CompoundTree(CompoundTreeNode(rootCompound!));
    await tree.root.addChildrenRecursively(databaseInterface);
    return tree;
  }

  void forEach(void Function(CompoundTreeNode) callback) {
    root.forEach(callback);
  }

  List<Compound> getAllCompounds() {
    final compounds = <Compound>[];
    forEach((node) => compounds.add(node.compound));
    return compounds;
  }

  List<Compound> getLeaveCompounds() {
    final compounds = <Compound>[];
    forEach((node) {
      if (node.isLeaf) {
        compounds.add(node.compound);
      }
    });
    return compounds;
  }
}

class CompoundTreeNode {
  final Compound compound;
  CompoundTreeNode? left;
  CompoundTreeNode? right;

  CompoundTreeNode(this.compound);

  bool get isLeaf => left == null && right == null;

  void forEach(void Function(CompoundTreeNode) callback) {
    callback(this);
    left?.forEach(callback);
    right?.forEach(callback);
  }

  Future<void> addChildrenRecursively(DatabaseInterface databaseInterface) async {
    final leftString = compound.modifier;
    final rightString = compound.head;

    final leftCompound = await databaseInterface.getCompoundByName(leftString);
    if (leftCompound != null) {
      left = CompoundTreeNode(leftCompound);
      await left!.addChildrenRecursively(databaseInterface);
    }

    final rightCompound = await databaseInterface.getCompoundByName(rightString);
    if (rightCompound != null) {
      right = CompoundTreeNode(rightCompound);
      await right!.addChildrenRecursively(databaseInterface);
    }
  }
}

abstract class BigCompoundGenerator {
  final DatabaseInterface databaseInterface;

  BigCompoundGenerator(this.databaseInterface);

  Future<CompoundTree> generate({
    int? seed,
  }) async {
    final compounds = await _readPossibleBigCompounds();

    final rootString = compounds[Random(seed).nextInt(compounds.length)];
    final rootCompound = await databaseInterface.getCompoundByName(rootString);
    final tree = CompoundTree.generate(databaseInterface: databaseInterface, rootString: rootString);

    return tree;
  }

  /// Read the compounds from the assets/compounds_with_level.csv file
  Future<List<String>> _readPossibleBigCompounds() async {
    final compoundOrigin = CompoundOrigin("assets/compounds_with_level.csv");
    final compounds = await compoundOrigin.getCompounds();
    return compounds.map((compound) => compound.name).toList();
  }
}
