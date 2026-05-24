import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize({bool requestPermissions = true}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: requestPermissions,
      requestBadgePermission: requestPermissions,
      requestSoundPermission: requestPermissions,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create the notification channels explicitly for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_reminders',
      'Prayer Reminders',
      description: 'Notifications for prayer times',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel channelWithAdhan = AndroidNotificationChannel(
      'prayer_reminders_adhan_v2',
      'Prayer Reminders with Adhan',
      description: 'Notifications for prayer times with Adhan sound',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adhan'),
      enableVibration: true,
    );

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.createNotificationChannel(channelWithAdhan);
    }

    // Request notification permissions only if requested (foreground only)
    if (requestPermissions) {
      await androidPlugin?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool playAdhan = false,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      playAdhan ? 'prayer_reminders_adhan_v2' : 'prayer_reminders',
      playAdhan ? 'Prayer Reminders with Adhan' : 'Prayer Reminders',
      channelDescription: playAdhan
          ? 'Notifications for prayer times with Adhan sound'
          : 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: playAdhan ? const RawResourceAndroidNotificationSound('adhan') : null,
      playSound: true,
    );

    final DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      sound: playAdhan ? 'adhan.mp3' : null,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showImmediateNotification(
    String title,
    String body, {
    bool playAdhan = false,
    int? id,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      playAdhan ? 'prayer_reminders_adhan_v2' : 'prayer_reminders',
      playAdhan ? 'Prayer Reminders with Adhan' : 'Prayer Reminders',
      channelDescription: playAdhan
          ? 'Notifications for prayer times with Adhan sound'
          : 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: playAdhan ? const RawResourceAndroidNotificationSound('adhan') : null,
      playSound: true,
    );

    final DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      sound: playAdhan ? 'adhan.mp3' : null,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notifications.show(
      id ?? DateTime.now().hashCode,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
    // Could navigate to specific screens or trigger actions
  }

  Future<bool> hasPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.requestNotificationsPermission() ?? false;
  }
}
