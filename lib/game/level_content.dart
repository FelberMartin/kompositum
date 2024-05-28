import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/unique_component.dart';

/// Class for the content of a level. This can simply be a list of compounds,
/// but can also be more advanced.
/// This class is then used to initialize a game level.
abstract class LevelContent {

  List<Compound> getCompounds();

  int get length => getCompounds().length;

}