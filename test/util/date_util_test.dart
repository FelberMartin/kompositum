import 'package:kompositum/util/date_util.dart';
import 'package:test/test.dart';

void main() {
  group('findNextSelectedDay', () {
    test('should return today if no completed days and this month' , () {
      final today = DateTime.now();
      final result = findNextDateInMonthNotInList(
        maxDate: today,
        excludeList: [],
        inMonth: today,
      );
      expect(result, isNotNull);
      expect(result!.day, today.day);
    });

    test('should return null if all days completed', () {
      final today = DateTime.now();
      final completedDays = List.generate(31, (index) => today.subtract(Duration(days: index)));
      final result = findNextDateInMonthNotInList(
        maxDate: today,
        excludeList: completedDays,
        inMonth: today,
      );
      expect(result, null);
    });

    test('should return first uncompleted day', () {
      final result = findNextDateInMonthNotInList(
        maxDate: DateTime(2023, 1, 10),
        excludeList: [
          DateTime(2023, 1, 10),
          DateTime(2023, 1, 9),
          DateTime(2023, 1, 8),
          DateTime(2023, 1, 6),
        ],
        inMonth: DateTime(2023, 1),
      );
      expect(result, isNotNull);
      expect(result!.day, 7);
    });

    test('should return the last day for a past month with no completed', () {
      final result = findNextDateInMonthNotInList(
        maxDate: DateTime(2023, 12, 20),
        excludeList: [],
        inMonth: DateTime(2021, 1),
      );
      expect(result, isNotNull);
      expect(result!.day, 31);
    });

    test('should return yesterday if today is completed', () {
      final result = findNextDateInMonthNotInList(
        maxDate: DateTime(2023, 1, 10),
        excludeList: [
          DateTime(2023, 1, 10),
        ],
        inMonth: DateTime(2023, 1),
      );
      expect(result, isNotNull);
      expect(result!.day, 9);
    });

    test('should return null if the maxDate is in the past', () {
      final result = findNextDateInMonthNotInList(
        maxDate: DateTime(2021, 1, 10),
        excludeList: [],
        inMonth: DateTime(2023, 1),
      );
      expect(result, null);
    });
  });
}