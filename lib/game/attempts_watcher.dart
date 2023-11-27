
class AttemptsWatcher {

  final int maxAttempts;
  int _attemptsLeft;
  int get attemptsLeft => _attemptsLeft;

  final Function onNoAttemptsLeft;

  AttemptsWatcher({
    required this.maxAttempts,
    required this.onNoAttemptsLeft
  }) : _attemptsLeft = maxAttempts;

  void attemptUsed() {
    _attemptsLeft--;
    if (_attemptsLeft == 0) {
      onNoAttemptsLeft();
    }
  }

  void resetAttempts() {
    _attemptsLeft = maxAttempts;
  }

  bool anyAttemptsLeft() {
    return _attemptsLeft > 0;
  }
}