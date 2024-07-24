import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/CalendarEvent.dart';


class CalendarEventService {
  final CollectionReference calendarEventsCollection =
  FirebaseFirestore.instance.collection('calendar_events');

  Future<void> saveCalendarEvent(CalendarEvent event) async {
    await calendarEventsCollection.doc(event.id).set({
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'professor': {
        'id': event.professor.id,
        'firstName': event.professor.firstName,
        'lastName': event.professor.lastName,
        'email': event.professor.email,
      },
      'room': {
        'id': event.room.id,
        'name': event.room.name,
        'building': event.room.building,
        'floor': event.room.floor,
        'seats': event.room.seats,
      },
      'startTime': event.startTime,
      'endTime': event.endTime,
      'course': {
        'courseId': event.course.courseId,
        'courseName': event.course.courseName,
        'courseFullName':event.course.courseFullName
      },
    });
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    await calendarEventsCollection.doc(eventId).delete();
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    await calendarEventsCollection.doc(event.id).update({
      'title': event.title,
      'description': event.description,
      'professor': {
        'id': event.professor.id,
        'firstName': event.professor.firstName,
        'lastName': event.professor.lastName,
        'email': event.professor.email,
      },
      'room': {
        'id': event.room.id,
        'name': event.room.name,
        'building': event.room.building,
        'floor': event.room.floor,
        'seats': event.room.seats,
      },
      'startTime': event.startTime,
      'endTime': event.endTime,
      'course': {
        'courseId': event.course.courseId,
        'courseName': event.course.courseName,
        'courseFullName': event.course.courseFullName,
      },
    });
  }

  Future<List<CalendarEvent>> getEventsForDay(String formattedDate) async {
    DateTime startOfDay = DateTime.parse(formattedDate);
    DateTime endOfDay = startOfDay.add(Duration(hours: 23, minutes: 59, seconds: 59));

    var querySnapshot = await calendarEventsCollection
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    List<CalendarEvent> events = querySnapshot.docs
        .map((doc) => CalendarEvent.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return events;
  }
}
