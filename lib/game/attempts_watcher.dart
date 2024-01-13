
class AttemptsWatcher {

  final int maxAttempts;
  int _attemptsLeft;
  int _overAllAttemptsFailed = 0;
  int get attemptsLeft => _attemptsLeft;
  int get attemptsFailed => maxAttempts - _attemptsLeft;
  int get overAllAttemptsFailed => _overAllAttemptsFailed;

  AttemptsWatcher({
    required this.maxAttempts,
  }) : _attemptsLeft = maxAttempts;

  void attemptUsed() {
    _attemptsLeft--;
    _overAllAttemptsFailed++;
  }

  void resetAttempts() {
    _attemptsLeft = maxAttempts;
  }

  bool anyAttemptsLeft() {
    return _attemptsLeft > 0;
  }
}