import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {

  Future<String?> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      final androidIdPlugin = AndroidId();
      return androidIdPlugin.getId(); // unique ID on Android
    }
  }

  Future<int> getDeviceSpecificSeed() async {
    var id = await getId();
    return id.hashCode;
  }
}