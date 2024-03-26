import 'package:kompositum/util/app_version_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAppVersionProvider extends Mock implements AppVersionProvider {
  bool didAppVersionChange = false;
}