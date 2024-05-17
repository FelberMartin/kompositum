
class AttemptsWatcher {

  final int maxAttempts;
  int _attemptsLeft;
  int _overAllAttemptsFailed = 0;

  int get attemptsLeft => _attemptsLeft;
  int get attemptsFailed => maxAttempts - _attemptsLeft;
  int get overAllAttemptsFailed => _overAllAttemptsFailed;

  final List<String> _usedAttempts = [];

  AttemptsWatcher({
    this.maxAttempts = 5,
  }) : _attemptsLeft = maxAttempts;

  void attemptUsed(String modifier, String head) {
    if (_usedAttempts.contains(modifier + head)) {
      return;
    }
    _usedAttempts.add(modifier + head);
    _attemptsLeft--;
    _overAllAttemptsFailed++;
  }

  /// Resets the local attempts, but keeps the overall attempts failed.
  void resetLocalAttempts() {
    _attemptsLeft = maxAttempts;
  }

  /// Resets all attempts, including the overall attempts failed. For when the level is reset.
  void resetAllAttempts() {
    resetLocalAttempts();
    _overAllAttemptsFailed = 0;
    _usedAttempts.clear();
  }

  bool anyAttemptsLeft() {
    return _attemptsLeft > 0;
  }

  bool allAttemptsUsed() {
    return !anyAttemptsLeft();
  }

  static AttemptsWatcher fromJson(Map<String, dynamic> json) {
    final result = AttemptsWatcher(maxAttempts: json['maxAttempts']);
    result._attemptsLeft = json['attemptsLeft'];
    result._overAllAttemptsFailed = json['overAllAttemptsFailed'];
    if (json.containsKey('usedAttempts')) {
      result._usedAttempts.addAll(
          (json['usedAttempts'] as List).cast<String>());
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'maxAttempts': maxAttempts,
      'attemptsLeft': _attemptsLeft,
      'overAllAttemptsFailed': _overAllAttemptsFailed,
      'usedAttempts': _usedAttempts,
    };
  }
}