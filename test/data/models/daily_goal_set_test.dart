import 'package:kompositum/data/models/daily_goal_set.dart';
import 'package:test/test.dart';

void main() {
  group("generate", () {
    test("Creates a DailyGoalSet with 3 distinct goals", () {
      final goalSet = DailyGoalSet.generate(creationSeed: 0, date: DateTime.now());
      expect(goalSet.goals.length, 3);
      expect(goalSet.goals[0].runtimeType, isNot(goalSet.goals[1].runtimeType));
      expect(goalSet.goals[1].runtimeType, isNot(goalSet.goals[2].runtimeType));
      expect(goalSet.goals[2].runtimeType, isNot(goalSet.goals[0].runtimeType));
    });

    test("Creates the same goalSet when called with the same seed value", () {
      final goalSet1 = DailyGoalSet.generate(creationSeed: 0, date: DateTime.now());
      final goalSet2 = DailyGoalSet.generate(creationSeed: 0, date: DateTime.now());
      expect(goalSet1.goals[0], goalSet2.goals[0]);
      expect(goalSet1.goals[1], goalSet2.goals[1]);
      expect(goalSet1.goals[2], goalSet2.goals[2]);
    });
  });

  group("json", () {
    test("toJson and fromJson are inverses", () {
      final goalSet = DailyGoalSet.generate(creationSeed: 0, date: DateTime.now());
      final json = goalSet.toJson();
      final goalSet2 = DailyGoalSet.fromJson(map: json, creationSeed: 0);
      expect(goalSet.date, goalSet2.date);
      expect(goalSet.goals[0], goalSet2.goals[0]);
      expect(goalSet.goals[1], goalSet2.goals[1]);
      expect(goalSet.goals[2], goalSet2.goals[2]);
    });
  });
}