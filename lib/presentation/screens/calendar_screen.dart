import 'package:classly/application/services/AuthService.dart';
import 'package:classly/application/services/UserService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../application/services/CourseService.dart';
import '../../application/services/EventService.dart';
import '../../application/services/NotificationsService.dart';
import '../../domain/models/CalendarEvent.dart';
import '../../domain/models/CustomUser.dart';
import '../widgets/add_event_form.dart';
import '../widgets/weather_widget.dart';
import 'event_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<CalendarEvent> appointments = [];
  MeetingDataSource? events;
  CustomUser? currentUser;
  final EventService eventService = EventService();
  final CourseService courseService = CourseService();
  final NotificationsService notificationsService = NotificationsService();
  final AuthService authService = AuthService();
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadEventsForCurrentDay(DateTime.now());
  }

  Future<void> _loadUser() async {
    User? user = await authService.getCurrentUser();
    CustomUser? customUser = await userService.getUser(user!.uid);
    setState(() {
      currentUser = customUser;
    });
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
    return Scaffold(
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
            appointmentTextStyle: GoogleFonts.poppins(
                color: Colors.white
            ),
            headerStyle: CalendarHeaderStyle(
                textStyle: GoogleFonts.poppins()
            ),
            viewHeaderStyle: ViewHeaderStyle(
                dateTextStyle: GoogleFonts.poppins(),
                dayTextStyle: GoogleFonts.poppins()
            ),
            allowedViews: [
              CalendarView.day,
              CalendarView.week,
              CalendarView.month,
            ],
            onTap: (CalendarTapDetails details) {
              if (details.appointments != null &&
                  details.appointments!.isNotEmpty) {
                _showEventDetailsDialog(details.appointments![0]);
              } else if (details.targetElement ==
                  CalendarElement.calendarCell) {
                _showAddEventForm(details.date!);
              }
            },
            onViewChanged: (ViewChangedDetails details) {
              _loadEventsForCurrentDay(details.visibleDates[0]);
            },
          ),
        ],
      ),
      floatingActionButton: currentUser?.isProfessor == true
          ? FloatingActionButton(
        onPressed: () {
          _showAddEventForm(DateTime.now());
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Future<void> _showAddEventForm(DateTime selectedDate) async {
    await showDialog(
      context: context,
      builder: (context) => AddEventForm(
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
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<CalendarEvent> source) {
    appointments = source;
  }
}
