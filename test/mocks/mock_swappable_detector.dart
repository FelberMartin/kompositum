import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/game/swappable_detector.dart';
import 'package:mocktail/mocktail.dart';

class MockSwappableDetector extends Mock implements SwappableDetector {
  @override
  Future<List<Swappable>> getSwappables(List<Compound> compounds) {
    return Future.value([]);
  }
}