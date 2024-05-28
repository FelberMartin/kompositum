import 'package:kompositum/game/level_setup.dart';
import 'package:kompositum/game/modi/classic/classic_game_level.dart';
import 'package:kompositum/util/tutorial_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockTutorialManager extends Mock implements TutorialManager {

  @override
  int get showClickIndicatorIndex => -1;

  @override
  void onNewLevelStart(LevelSetup levelSetup, ClassicGameLevel poolGameLevel) {}

  @override
  void onCombinedInvalidCompound(ClassicGameLevel poolGameLevel) {}

  @override
  void onComponentClicked() {}
}