import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../data/repositories/NotificationsRepository.dart';
import '../../domain/models/AppNotification.dart';
import '../../domain/models/CalendarEvent.dart';

class NotificationsService {
  final NotificationsRepository _repository = NotificationsRepository();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationsService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleEventNotifications(CalendarEvent event) async {
    DateTime oneDayBefore = event.startTime.subtract(const Duration(days: 1));
    DateTime fifteenMinutesBefore = event.startTime.subtract(const Duration(minutes: 15));

    if (oneDayBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        event.id.hashCode,
        'Event Reminder',
        'You have a class tomorrow: ${event.title}.',
        oneDayBefore,
      );
    }

    if (fifteenMinutesBefore.isAfter(DateTime.now())) {
      await scheduleNotification(
        event.id.hashCode + 1,
        'Event Reminder',
        'Your event ${event.title} starts soon!',
        fifteenMinutesBefore,
      );
    }
  }

  Future<void> scheduleNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    final today = DateTime.now();

    if (scheduledDate.year == today.year &&
        scheduledDate.month == today.month &&
        scheduledDate.day == today.day) {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'Classly',
            'Classly Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );

      await _repository.saveNotification(
        id: id.toString(),
        title: title,
        body: body,
        dateTime: today,
      );
    } else {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'Classly',
            'Classly Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      await _repository.saveNotification(
        id: id.toString(),
        title: title,
        body: body,
        dateTime: scheduledDate,
      );
    }
  }

  Future<List<AppNotification>> getNotifications() async {
    return await _repository.getNotificationsFromFirebase();
  }

  Future<List<ActiveNotification>> getActiveNotifications() {
    return _flutterLocalNotificationsPlugin.getActiveNotifications();
  }

  Future<void> cancelNotification(int id) async{
    return await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async{
    return await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
