import 'package:kompositum/game/hints/hint.dart';
import 'package:kompositum/game/pool_game_level.dart';

import '../../data/models/compound.dart';
import '../level_provider.dart';

abstract class GameEvent {
  const GameEvent();
}


/// When a new level is started.
class NewLevelStartGameEvent extends GameEvent {
  final LevelSetup levelSetup;
  final PoolGameLevel poolGameLevel;

  const NewLevelStartGameEvent(this.levelSetup, this.poolGameLevel);
}

/// When a level is completed.
class LevelCompletedGameEvent extends GameEvent {
  final LevelSetup levelSetup;
  final PoolGameLevel poolGameLevel;

  const LevelCompletedGameEvent(this.levelSetup, this.poolGameLevel);
}

/// When a component in the pool is clicked.
class ComponentClickedGameEvent extends GameEvent {
  const ComponentClickedGameEvent();
}

/// When a correct compound is combined.
class CompoundFoundGameEvent extends GameEvent {
  final Compound compound;

  const CompoundFoundGameEvent(this.compound);
}

/// When the combined compound is invalid.
class CompoundInvalidGameEvent extends GameEvent {
  final PoolGameLevel poolGameLevel;

  const CompoundInvalidGameEvent(this.poolGameLevel);
}

/// When the star count should be increased.
class StarIncreaseRequestGameEvent extends GameEvent {
  final int amount;
  final StarIncreaseRequestOrigin origin;

  StarIncreaseRequestGameEvent(this.amount, this.origin);
}

enum StarIncreaseRequestOrigin {
  compoundCompletion,
  levelCompletion,
}


/// When a hint is bought.
class HintBoughtGameEvent extends GameEvent {
  final Hint hint;

  const HintBoughtGameEvent(this.hint);
}

