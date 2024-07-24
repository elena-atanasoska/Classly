import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../application/services/CourseService.dart';
import '../../application/services/EventService.dart';
import '../../application/services/NotificationsService.dart';
import '../../domain/models/CalendarEvent.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/weather_widget.dart';
import 'event_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<CalendarEvent> appointments = [];
  MeetingDataSource? events;
  final EventService eventService = EventService();
  final CourseService courseService = CourseService();
  final NotificationsService notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _loadEventsForCurrentDay(DateTime.now());
  }

  Future<void> _loadEventsForCurrentDay(DateTime date) async {
    List<CalendarEvent> eventsForCurrentDay =
        await eventService.getEventsForDay(date);

    setState(() {
      appointments = eventsForCurrentDay;
      events = MeetingDataSource(appointments);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Calendar'),
          actions: [
            WeatherWidget(),
          ],
        ),
        body: Stack(
          children: [
            SfCalendar(
              view: CalendarView.day,
              dataSource: events,
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null &&
                    details.appointments!.isNotEmpty) {
                  _showEventDetailsDialog(details.appointments![0]);
                } else if (details.targetElement ==
                    CalendarElement.calendarCell) {
                  _showAddEventDialog(details.date!);
                }
              },
              onViewChanged: (ViewChangedDetails details) {
                _loadEventsForCurrentDay(details.visibleDates[0]);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddEventDialog(DateTime.now());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddEventDialog(DateTime selectedDate) async {
    await showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: selectedDate,
        onAddEvent: (CalendarEvent event) async {
          await eventService.saveEvent(event);
          _loadEventsForCurrentDay(selectedDate);
        },
      ),
    );
  }

  Future<void> _showEventDetailsDialog(CalendarEvent event) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventScreen(),
      ),
    );
  }

// Future<void> _showEventDetailsDialog(CalendarEvent event) async {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => EventScreen(
//           event: event, onDelete: _deleteEvent, onEdit: _editEvent),
//     ),
//   );
//
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<CalendarEvent> source) {
    appointments = source;
  }
}
