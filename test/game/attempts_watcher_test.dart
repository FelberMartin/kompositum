import 'package:kompositum/game/attempts_watcher.dart';
import 'package:test/test.dart';

void main() {
  test('attemptUsed should reduce the number of attempts', () {
    final sut = AttemptsWatcher(maxAttempts: 3);
    expect(sut.attemptsLeft, 3);
    sut.attemptUsed("Blau", "Apfel");
    expect(sut.attemptsLeft, 2);
  });

  test('resetAttempts should reset the number of attempts', () {
    final sut = AttemptsWatcher(maxAttempts: 3);
    expect(sut.attemptsLeft, 3);
    sut.attemptUsed("Blau", "Apfel");
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
    sut.attemptUsed("Blau", "Apfel");
    sut.attemptUsed("Apfel", "Blau");
    sut.attemptUsed("Grün", "Auto");
    expect(sut.anyAttemptsLeft(), false);
  });

  test('should only reduce the attempts count once, if the same head + modifier are used multiple times', () {
    final sut = AttemptsWatcher(maxAttempts: 3);
    expect(sut.attemptsLeft, 3);
    sut.attemptUsed("Blau", "Apfel");
    expect(sut.attemptsLeft, 2);
    sut.attemptUsed("Blau", "Apfel");
    expect(sut.attemptsLeft, 2);
  });

}