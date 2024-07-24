import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../domain/models/AppNotification.dart';

class NotificationsService {
  final CollectionReference notificationsCollection =
  FirebaseFirestore.instance.collection('notifications');

  Future<void> saveNotification({
    required String id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await notificationsCollection.doc(id).set({
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime,
    });
  }


  Future<void> scheduleEventNotification(
      DateTime eventDate, String eventTitle) async {
    if (eventDate
        .subtract(const Duration(days: 1))
        .isBefore(DateTime.now())) {
      return;
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

    await flutterLocalNotificationsPlugin.zonedSchedule(
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

  Future<List<AppNotification>> getNotificationsFromFirebase() async {
      var querySnapshot = await notificationsCollection.get();

      List<AppNotification> notifications = querySnapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return notifications;
  }
}