import 'package:kompositum/util/feature_lock_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockFeatureLockManager extends Mock implements FeatureLockManager {

  @override
  var isDailyLevelFeatureLocked = false;

  @override
  var isDailyGoalsFeatureLocked = false;
}