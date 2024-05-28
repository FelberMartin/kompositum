import 'package:kompositum/util/app_version_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAppVersionProvider extends Mock implements AppVersionProvider {
  Future<bool> didAppVersionChange = Future.value(false);
  String appVersion = "1.0.0";

  @override
  Future<String> getAppVersion() {
    return Future.value(appVersion);
  }
}