import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/level_content.dart';

class ClassicLevelContent extends LevelContent {
  final List<Compound> compounds;

  ClassicLevelContent(this.compounds);

  @override
  List<Compound> getCompounds() {
    return compounds;
  }

  @override
  List<UniqueComponent> selectableComponents() {
    return UniqueComponent.fromCompounds(compounds);
  }
}