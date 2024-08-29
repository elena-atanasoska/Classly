import '../../data/repositories/EventRepository.dart';
import '../../domain/models/CalendarEvent.dart';

class EventService {
  final EventRepository _eventRepository = EventRepository();

  Future<void> saveEvent(CalendarEvent event) async {
    await _eventRepository.saveCalendarEvent(event);
  }

  Future<void> updateEvent(CalendarEvent event) async {
    await _eventRepository.updateCalendarEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventRepository.deleteCalendarEvent(eventId);
  }

  Future<List<CalendarEvent>> getEventsForDay(DateTime date, List<String> enrolledCourseIds) async {
    return await _eventRepository.getEventsForDay(date, enrolledCourseIds);
  }

  Future<CalendarEvent> getEventById(String id) async {
    return await _eventRepository.getEventById(id);
  }

  Future<List<CalendarEvent>> getEventsForDateRange(DateTime startDate, DateTime endDate, List<String> enrolledCourseIds) async {
    return await _eventRepository.getEventsForDateRange(startDate, endDate, enrolledCourseIds);
  }
}