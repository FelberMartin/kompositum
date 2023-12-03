import 'package:kompositum/game/attempts_watcher.dart';
import 'package:test/test.dart';

void main() {
  test('attemptUsed should reduce the number of attempts', () {
    final sut = AttemptsWatcher(maxAttempts: 3);
    expect(sut.attemptsLeft, 3);
    sut.attemptUsed();
    expect(sut.attemptsLeft, 2);
  });

  test('resetAttempts should reset the number of attempts', () {
    final sut = AttemptsWatcher(maxAttempts: 3);
    expect(sut.attemptsLeft, 3);
    sut.attemptUsed();
    expect(sut.attemptsLeft, 2);
    sut.resetAttempts();
    expect(sut.attemptsLeft, 3);
  });

  test('anyAttemptsLeft should return true if attempts are left', () {
    final sut = AttemptsWatcher(maxAttempts: 3);
    expect(sut.anyAttemptsLeft(), true);
  });

  test('anyAttemptsLeft should return false if no attempts are left', () {
    final sut = AttemptsWatcher(maxAttempts: 3);
    sut.attemptUsed();
    sut.attemptUsed();
    sut.attemptUsed();
    expect(sut.anyAttemptsLeft(), false);
  });

}