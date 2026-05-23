import 'package:flutter/services.dart';

class PlatformChannelService {
  static const MethodChannel _permissionsChannel = MethodChannel('com.sajda.sajda_app/permissions');
  static const MethodChannel _lockChannel = MethodChannel('com.sajda.sajda_app/lock');

  static Future<bool> checkOverlayPermission() async {
    try {
      final bool result = await _permissionsChannel.invokeMethod('checkOverlayPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestOverlayPermission() async {
    try {
      final bool result = await _permissionsChannel.invokeMethod('requestOverlayPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> checkBatteryOptimization() async {
    try {
      final bool result = await _permissionsChannel.invokeMethod('checkBatteryOptimization');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestBatteryOptimization() async {
    try {
      final bool result = await _permissionsChannel.invokeMethod('requestBatteryOptimization');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> startLockOverlay(String prayerName, int durationSeconds) async {
    try {
      await _lockChannel.invokeMethod('startLock', {
        'prayerName': prayerName,
        'duration': durationSeconds,
      });
    } on PlatformException {
      // Ignore errors
    }
  }

  static Future<void> stopLockOverlay() async {
    try {
      await _lockChannel.invokeMethod('stopLock');
    } on PlatformException {
      // Ignore errors
    }
  }

  static Future<void> scheduleNativeAlarm(String prayerName, int durationSeconds, DateTime triggerAt, {String? nextPrayerText}) async {
    try {
      await _lockChannel.invokeMethod('scheduleNativeAlarm', {
        'prayerName': prayerName,
        'duration': durationSeconds,
        'triggerAt': triggerAt.millisecondsSinceEpoch,
        if (nextPrayerText != null) 'nextPrayerText': nextPrayerText,
      });
    } on PlatformException {
      // Ignore errors
    }
  }
  static Future<Map<String, dynamic>?> getInitialIntent() async {
    try {
      final Map<dynamic, dynamic>? result = await _lockChannel.invokeMapMethod('getInitialIntent');
      return result?.cast<String, dynamic>();
    } on PlatformException {
      return null;
    }
  }

  static void setReflectionHandler(Future<void> Function(String prayerName) handler) {
    _lockChannel.setMethodCallHandler((call) async {
      if (call.method == 'onReflectionTriggered') {
        final prayerName = call.arguments['prayerName'] as String;
        await handler(prayerName);
      }
    });
  }
}
