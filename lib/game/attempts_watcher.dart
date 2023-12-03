
class AttemptsWatcher {

  final int maxAttempts;
  int _attemptsLeft;
  int get attemptsLeft => _attemptsLeft;

  AttemptsWatcher({
    required this.maxAttempts,
  }) : _attemptsLeft = maxAttempts;

  void attemptUsed() {
    _attemptsLeft--;
  }

  void resetAttempts() {
    _attemptsLeft = maxAttempts;
  }

  bool anyAttemptsLeft() {
    return _attemptsLeft > 0;
  }
}