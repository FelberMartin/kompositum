import 'package:kompositum/util/device_info.dart';

class MockDeviceInfo extends DeviceInfo {

  @override
  Future<String?> getId() async {
    return "mock_id";
  }

}