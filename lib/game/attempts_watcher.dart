
class AttemptsWatcher {

  final int maxAttempts;
  int _attemptsLeft;
  int _overAllAttemptsFailed = 0;

  int get attemptsLeft => _attemptsLeft;
  int get attemptsFailed => maxAttempts - _attemptsLeft;
  int get overAllAttemptsFailed => _overAllAttemptsFailed;

  AttemptsWatcher({
    this.maxAttempts = 5,
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

  static AttemptsWatcher fromJson(Map<String, dynamic> json) {
    final result = AttemptsWatcher(maxAttempts: json['maxAttempts']);
    result._attemptsLeft = json['attemptsLeft'];
    result._overAllAttemptsFailed = json['overAllAttemptsFailed'];
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'maxAttempts': maxAttempts,
      'attemptsLeft': _attemptsLeft,
      'overAllAttemptsFailed': _overAllAttemptsFailed,
    };
  }
}