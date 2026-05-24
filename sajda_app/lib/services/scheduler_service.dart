import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../models/prayer.dart';
import 'prayer_time_service.dart';
import 'notification_service.dart';
import 'database_service.dart';
import 'platform_channel_service.dart';
import 'alarm_callback.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';

@pragma('vm:entry-point')
void dailyRefreshCallback(int id, Map<String, dynamic> data) async {
  stdout.writeln('!!! SAJDA_DEBUG: Daily refresh triggered !!!');
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferences.getInstance();
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    await DatabaseService.instance.getAppSettings(); // ensure DB initialized
    await SchedulerService().reschedule();
    stdout.writeln('!!! SAJDA_DEBUG: Daily refresh complete !!!');
  } catch (e, stack) {
    stdout.writeln('!!! SAJDA_DEBUG: DAILY REFRESH CRASHED: $e !!!');
  }
}

class SchedulerService {
  static final SchedulerService _instance = SchedulerService._internal();
  factory SchedulerService() => _instance;
  SchedulerService._internal();

  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  final NotificationService _notificationService = NotificationService();
  final DatabaseService _db = DatabaseService.instance;

  bool _isRunning = false;

  Future<void> start() async {
    if (_isRunning) return;
    
    _isRunning = true;
    await _schedulePrayerNotifications();
    await _scheduleAlarms();
  }

  Future<void> stop() async {
    _isRunning = false;
    await _notificationService.cancelAllNotifications();
    await _cancelAllAlarms();
  }

  Future<void> _schedulePrayerNotifications() async {
    // We now use AndroidAlarmManager for all notifications because flutter_local_notifications 
    // zonedSchedule is unreliable in Doze mode, especially for custom sounds like Adhan.
    // This method is kept empty but exists for interface compatibility.
    await _notificationService.cancelAllNotifications();
  }

  Future<void> _scheduleAlarms() async {
    try {
      final prayers = await _prayerTimeService.calculatePrayerTimes();
      final settings = await _db.getAppSettings();
      final gracePeriod = Duration(minutes: settings?.gracePeriodMinutes ?? 5);
      final lockDurationSeconds = (settings?.lockDurationMinutes ?? 10) * 60;
      final playAdhan = settings?.playAdhan ?? false;
      final now = DateTime.now();

      await _cancelAllAlarms();

      for (final prayer in prayers) {
        if (!prayer.enabled) continue;

        // 1. Schedule Adhan / Reminder at EXACT prayer time
        if (prayer.time.isAfter(now)) {
          final adhanAlarmId = prayer.name.index * 2;
          if (Platform.isAndroid) {
            await AndroidAlarmManager.oneShotAt(
              prayer.time,
              adhanAlarmId,
              alarmCallback,
              params: {
                'prayerName': prayer.name.displayName,
                'durationSeconds': lockDurationSeconds,
                'playAdhan': playAdhan,
              },
              exact: true,
              wakeup: true,
            );
          }
          debugPrint('SAJDA_DEBUG: Adhan alarm for ${prayer.name.displayName} scheduled at ${prayer.time}');
        }

        // 2. Schedule Native Lock Overlay at lockTriggerTime
        final lockTriggerTime = prayer.time.add(gracePeriod);
        if (lockTriggerTime.isAfter(now)) {
          
          final nextPrayerIdx = (prayers.indexOf(prayer) + 1) % prayers.length;
          final nextPrayer = prayers[nextPrayerIdx];
          int hour = nextPrayer.time.hour;
          String amPm = hour >= 12 ? 'PM' : 'AM';
          hour = hour % 12;
          if (hour == 0) hour = 12;
          String minute = nextPrayer.time.minute.toString().padLeft(2, '0');
          final nextPrayerText = 'Next: ${nextPrayer.name.displayName} at $hour:$minute $amPm';

          // Schedule NATIVE lock screen alarm for 100% reliability
          await PlatformChannelService.scheduleNativeAlarm(
            prayer.name.displayName,
            lockDurationSeconds,
            lockTriggerTime,
            nextPrayerText: nextPrayerText,
          );
          debugPrint('SAJDA_DEBUG: Lock alarm for ${prayer.name.displayName} scheduled at $lockTriggerTime');
        }
      }

      // Schedule daily refresh alarm for 1 AM
      var nextRefresh = DateTime(now.year, now.month, now.day, 1, 0);
      if (now.isAfter(nextRefresh)) {
        nextRefresh = nextRefresh.add(const Duration(days: 1));
      }
      if (Platform.isAndroid) {
        await AndroidAlarmManager.oneShotAt(
          nextRefresh,
          999, // Use 999 for daily refresh
          dailyRefreshCallback,
          exact: true,
          wakeup: true,
        );
      }
      debugPrint('SAJDA_DEBUG: Daily refresh alarm scheduled at $nextRefresh');

    } catch (e) {
      debugPrint('SAJDA_DEBUG: Error scheduling alarms: $e');
    }
  }

  Future<void> _cancelAllAlarms() async {
    if (!Platform.isAndroid) return;
    for (var i = 0; i < 10; i++) {
      await AndroidAlarmManager.cancel(i);
    }
    await AndroidAlarmManager.cancel(999);
  }

  Future<void> reschedule() async {
    if (_isRunning) {
      await _schedulePrayerNotifications();
      await _scheduleAlarms();
    }
  }

  bool get isRunning => _isRunning;
}
