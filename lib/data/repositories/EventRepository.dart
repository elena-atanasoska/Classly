import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/CalendarEvent.dart';

class EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CalendarEvent> getEventById(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection('calendarEvents').doc(id).get();

      if (documentSnapshot.exists) {
        return CalendarEvent.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      } else {
        throw Exception('Event not found');
      }
    } catch (error) {
      print('Error fetching event by ID: $error');
      rethrow;
    }
  }

  Future<void> saveCalendarEvent(CalendarEvent event) async {
    await _firestore.collection('calendarEvents').doc(event.id).set(event.toMap());
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    await _firestore.collection('calendarEvents').doc(event.id).update(event.toMap());
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    await _firestore.collection('calendarEvents').doc(eventId).delete();
  }

  Future<List<CalendarEvent>> getEventsForDay(DateTime date, List<String> enrolledCourseIds) async {
    try {
      Query query = _firestore
          .collection('calendarEvents')
          .where('startTime', isGreaterThanOrEqualTo: DateTime.parse(formatDate(date)))
          .where('startTime', isLessThanOrEqualTo: DateTime.parse(formatDate(date)).add(const Duration(days: 1)))
          .where('course.courseId', whereIn: enrolledCourseIds);

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs.map((DocumentSnapshot document) {
        return CalendarEvent.fromMap(document.data() as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      print('Error fetching events for day: $error');
      return [];
    }
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
}
