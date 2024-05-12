import '../../objectbox.g.dart';
import 'daily_goal.dart';

@Entity()
class DailyGoalSet {
  @Id()
  int id;

  @Index()
  final DateTime date;
  final List<DailyGoal> goals;

  DailyGoalSet({
    required this.id,
    required this.date,
    required this.goals,
  });

  bool get isAchieved => goals.every((goal) => goal.isAchieved);
  double get progress => goals.map((goal) => goal.progress).reduce((a, b) => a + b) / goals.length;
}