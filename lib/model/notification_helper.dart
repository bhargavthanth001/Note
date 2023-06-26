import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Noti {
  static Future initialize() async {
    var androidSetting =
        new AndroidInitializationSettings('@mipmap/ic_launcher');

    var iosSetting = new DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        defaultPresentSound: true,
        requestCriticalPermission: true);
    var initializationSetting =
        new InitializationSettings(android: androidSetting, iOS: iosSetting);
    await flutterLocalNotificationsPlugin.initialize(initializationSetting);
  }

  Future<void> showNotification(
      int id, String title, String body, DateTime dateTime) async {
    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        NotificationDetails(
            android: AndroidNotificationDetails(id.toString(), 'Go to Bad',
                importance: Importance.max,
                priority: Priority.max,
                icon: '@mipmap/ic_launcher')),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }
}
