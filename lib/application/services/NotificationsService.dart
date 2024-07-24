import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../data/repositories/NotificationsRepository.dart';
import '../../domain/models/AppNotification.dart';

class NotificationsService {
  final NotificationsRepository _repository = NotificationsRepository();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> saveNotification({
    required String id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _repository.saveNotification(
      id: id,
      title: title,
      body: body,
      dateTime: dateTime,
    );
  }

  Future<void> scheduleEventNotification(DateTime eventDate, String eventTitle) async {
    if (eventDate.subtract(const Duration(days: 1)).isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'classly1',
      'classly_notifications',
      channelDescription: 'classly notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Event Reminder',
      'You have a class tomorrow!',
      tz.TZDateTime.from(
        eventDate.subtract(const Duration(days: 1)),
        tz.getLocation("Europe/Skopje"),
      ),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<List<AppNotification>> getNotifications() async {
    return await _repository.getNotificationsFromFirebase();
  }
}
