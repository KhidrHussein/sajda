import 'dart:io';
import 'package:flutter/widgets.dart';
import '../models/prayer.dart';
import 'notification_service.dart';
import 'prayer_time_service.dart';

@pragma('vm:entry-point')
void alarmCallback(int id, Map<String, dynamic> data) async {
  // Use stdout.writeln as it's the most reliable for background isolates
  stdout.writeln('!!! SAJDA_DEBUG: Alarm callback triggered (ID: $id) !!!');
  debugPrint('!!! SAJDA_DEBUG: Alarm callback triggered (ID: $id) !!!');
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    final prayerName = data['prayerName'] as String? ?? 'Prayer';
    final playAdhan = data['playAdhan'] as bool? ?? false;
    final isLockNotification = data['isLockNotification'] as bool? ?? false;
    
    stdout.writeln('!!! SAJDA_DEBUG: Processing alarm for $prayerName !!!');
    
    // Initialize notification service - DO NOT request permissions in background
    final notificationService = NotificationService();
    await notificationService.initialize(requestPermissions: false);
    
    // Show notification
    stdout.writeln('!!! SAJDA_DEBUG: Showing notification !!!');
    
    final title = isLockNotification ? 'Prayer Lock' : 'Prayer Time';
    final body = isLockNotification ? 'Lock active for $prayerName' : 'Time for $prayerName';
    
    await notificationService.showImmediateNotification(
      title,
      body,
      playAdhan: playAdhan,
      id: id,
    );

    // Start lock overlay is handled by Native LockBroadcastReceiver to avoid ForegroundServiceStartNotAllowedException
    stdout.writeln('!!! SAJDA_DEBUG: Alarm processing complete !!!');
  } catch (e, stack) {
    stdout.writeln('!!! SAJDA_DEBUG: ALARM CALLBACK CRASHED !!!');
    stdout.writeln('Error: $e');
    stdout.writeln('Stack: $stack');
  }
}
