import 'package:permission_handler/permission_handler.dart';

class BatteryOptimizationService {
  static Future<bool> isIgnoringBatteryOptimizations() async {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (!await isIgnoringBatteryOptimizations()) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  static Future<bool> canScheduleExactAlarms() async {
    if (await Permission.scheduleExactAlarm.isGranted) {
      return true;
    }
    return false;
  }

  static Future<void> requestScheduleExactAlarmPermission() async {
    await Permission.scheduleExactAlarm.request();
  }

  static Future<bool> hasAllPermissions() async {
    return await canScheduleExactAlarms() && 
           await isIgnoringBatteryOptimizations();
  }
}
