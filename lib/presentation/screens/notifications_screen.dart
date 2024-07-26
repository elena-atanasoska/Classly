import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/services/NotificationsService.dart';
import '../../domain/models/AppNotification.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> notifications = [];
  final NotificationsService notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    List<AppNotification> fetchedNotifications = await notificationsService.getNotifications();

    setState(() {
      notifications = fetchedNotifications;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications,
              size: 100,
              color: Color(0xFF0D47A1),
            ),
            SizedBox(height: 20),
            Text(
              'No Notifications',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var groupedNotifications = groupNotificationsByDate(notifications);
          var dates = groupedNotifications.keys.toList()..sort((a, b) => b.compareTo(a));

          if (index < dates.length) {
            var date = dates[index];
            var dateNotifications = groupedNotifications[date]!;

            return Column(
              children: [
                ListTile(
                  title: Text(
                    formatDate(date),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
                ...dateNotifications.map((notification) {
                  return Card(
                    elevation: 2.0,
                    color: Color(0xFF0D47A1),
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                      ),
                      title: Text(notification.title, style: GoogleFonts.poppins(color: Colors.white)),
                      subtitle: Text(notification.body, style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  );
                }),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }

  Map<DateTime, List<AppNotification>> groupNotificationsByDate(List<AppNotification> notifications) {
    Map<DateTime, List<AppNotification>> groupedNotifications = {};

    for (var notification in notifications) {
      var date = DateTime(notification.dateTime.year, notification.dateTime.month, notification.dateTime.day);

      if (groupedNotifications.containsKey(date)) {
        groupedNotifications[date]!.add(notification);
      } else {
        groupedNotifications[date] = [notification];
      }
    }

    return groupedNotifications;
  }
}
