import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AlarmPermissionHelper {
  Future<bool> checkAndRequestPermission() async {
    if (Platform.isAndroid && await _isAndroid12OrHigher()) {
      if (await Permission.scheduleExactAlarm.isGranted) {
        return true; // Permission already granted
      } else {
        // Request permission
        return await Permission.scheduleExactAlarm.request().isGranted;
      }
    }
    return true; // No exact alarm restrictions for non-Android platforms or pre-Android 12
  }

  Future<bool> _isAndroid12OrHigher() async {
    int sdkVersion = await _getAndroidSdkVersion();
    return sdkVersion >= 31; // Android 12 is API level 31 or higher
  }

  Future<int> _getAndroidSdkVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0; // Return 0 for non-Android platforms
  }
}

