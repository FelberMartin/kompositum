import 'package:kompositum/game/attempts_watcher.dart';
import 'package:test/test.dart';

void main() {
  test('attemptUsed should reduce the number of attempts', () {
    final sut = AttemptsWatcher(maxAttempts: 3, onNoAttemptsLeft: () => {});
    expect(sut.attemptsLeft, 3);
    sut.attemptUsed();
    expect(sut.attemptsLeft, 2);
  });

  test('resetAttempts should reset the number of attempts', () {
    final sut = AttemptsWatcher(maxAttempts: 3, onNoAttemptsLeft: () => {});
    expect(sut.attemptsLeft, 3);
    sut.attemptUsed();
    expect(sut.attemptsLeft, 2);
    sut.resetAttempts();
    expect(sut.attemptsLeft, 3);
  });

  test('anyAttemptsLeft should return true if attempts are left', () {
    final sut = AttemptsWatcher(maxAttempts: 3, onNoAttemptsLeft: () => {});
    expect(sut.anyAttemptsLeft(), true);
  });

  test('anyAttemptsLeft should return false if no attempts are left', () {
    final sut = AttemptsWatcher(maxAttempts: 3, onNoAttemptsLeft: () => {});
    sut.attemptUsed();
    sut.attemptUsed();
    sut.attemptUsed();
    expect(sut.anyAttemptsLeft(), false);
  });

  test('attemptUsed should call the callback if no attempts are left', () {
    var callbackCalled = false;
    final sut = AttemptsWatcher(maxAttempts: 3, onNoAttemptsLeft: () => callbackCalled = true);
    sut.attemptUsed();
    sut.attemptUsed();
    sut.attemptUsed();
    expect(callbackCalled, true);
  });
}