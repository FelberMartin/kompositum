import 'package:kompositum/game/level_provider.dart';
import 'package:kompositum/game/pool_game_level.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockTutorialManager extends Mock implements TutorialManager {

  @override
  int get showClickIndicatorIndex => -1;

  @override
  void onNewLevelStart(LevelSetup levelSetup, PoolGameLevel poolGameLevel) {}

  @override
  void onCombinedInvalidCompound(PoolGameLevel poolGameLevel) {}

  @override
  void onComponentClicked() {}
}