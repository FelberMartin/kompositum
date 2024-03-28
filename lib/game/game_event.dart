import '../data/models/compound.dart';

abstract class GameEvent {
  const GameEvent();
}

/// When a correct compound is combined.
class CompoundFoundGameEvent extends GameEvent {
  final Compound compound;

  const CompoundFoundGameEvent(this.compound);
}

/// When the combined compound is invalid.
class CompoundInvalidGameEvent extends GameEvent {
  const CompoundInvalidGameEvent();
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