import 'package:kompositum/objectbox.g.dart';

@Entity()
class DailyGoal {

  @Id()
  int id;

  final String UiText;
  final int targetValue;
  final int currentValue;

  DailyGoal({
    required this.id,
    required this.UiText,
    required this.targetValue,
    required this.currentValue,
  });

  bool get isAchieved => currentValue >= targetValue;
  double get progress => currentValue / targetValue;

}