import 'package:kompositum/data/key_value_store.dart';
import 'package:kompositum/game/goals/daily_goal_set_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

import '../../mocks/mock_device_info.dart';

void main() {
  late DailyGoalSetManager sut;
  final keyValueStore = KeyValueStore();
  final deviceInfo = MockDeviceInfo();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sut = DailyGoalSetManager(keyValueStore, deviceInfo);
  });

  test('getProgression, The progression can be seen through the return value', () async {
    final goalSet = await sut.getDailyGoalSet();
    goalSet.goals[0].increaseCurrentValue(amount: 1);
    final progression = await sut.getProgression();
    expect(progression.previous, isNot(progression.current));
    expect(progression.previous.goals[0].currentValue, 0);
    expect(progression.current.goals[0].currentValue, 1);
  });

  test("resetProgression, The progression is reset to the current goal set", () async {
    final goalSet = await sut.getDailyGoalSet();
    goalSet.goals[0].increaseCurrentValue(amount: 1);
    final progression = await sut.getProgression();
    expect(progression.previous.goals[0].currentValue, 0);
    expect(progression.current.goals[0].currentValue, 1);
    sut.resetProgression();
    final resetProgression = await sut.getProgression();
    expect(resetProgression.previous.goals[0].currentValue, 1);
    expect(resetProgression.current.goals[0].currentValue, 1);
  });
}