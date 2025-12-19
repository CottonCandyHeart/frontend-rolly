import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/models/notification.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tzdata.initializeTimeZones();

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  const settings = InitializationSettings(
    android: android,
    iOS: ios,
  );

  await notifications.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final notificationId = response.id;

      if (notificationId != null) {
        await markAsRead(notificationId);
        await notifications.cancel(notificationId);
      }
    },
  );
}

Future<List<CustomNotification>> fetchNotifications(String token) async {
  final response = await http.get(
    Uri.parse('${AppConfig.notificationEndpoint}/'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  final List data = jsonDecode(response.body);

  return data
      .map((e) => CustomNotification.fromJson(e))
      .toList();
}

Future<void> syncNotificationsFromBackend(
  List<CustomNotification> notificationsFromApi,
) async {
  final prefs = await SharedPreferences.getInstance();
  final scheduledIds = prefs.getStringList('scheduled_notifications') ?? [];

  for (final n in notificationsFromApi) {
    if (n.read) continue;
    if (scheduledIds.contains(n.id.toString())) continue;

    await scheduleNotification(
      id: n.id,
      title: n.title,
      body: n.message,
      dateTime: n.sentAt,
    );

    scheduledIds.add(n.id.toString());
  }

  await prefs.setStringList('scheduled_notifications', scheduledIds);
}


Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime dateTime,
}) async {
  await notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(dateTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'training_channel',
        'Training reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Future<void> markAsRead(int id) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token')!;
  if (token == null || token.isEmpty) return;

  await http.post(
    Uri.parse('${AppConfig.markAsRead}/$id'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
}
