import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id ;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown-device';
      }
    } catch (e) {
      print("Device ID error: $e");
    }

    return 'unknown-device';
  }
}
