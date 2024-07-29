import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../application/services/NotificationsService.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<ActiveNotification> activeNotifications = [];
  final NotificationsService notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _loadActiveNotifications();
  }

  Future<void> _loadActiveNotifications() async {
    List<ActiveNotification> fetchedActiveNotifications = await notificationsService.getActiveNotifications();
    setState(() {
      activeNotifications = fetchedActiveNotifications;
    });
  }

  Future<void> _clearNotification(int id) async {
    await notificationsService.cancelNotification(id);
    _loadActiveNotifications();
  }

  Future<void> _clearAllNotifications() async {
    await notificationsService.cancelAllNotifications();
    _loadActiveNotifications();
  }

  Future<void> _showClearNotificationsDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Notifications', style: TextStyle(color: Color(0xFF0D47A1)),),
          content: Text('Do you want to clear all notifications?', style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Clear All'),
              onPressed: () async {
                await _clearAllNotifications();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showClearNotificationsDialog,
          ),
        ],
      ),
      body: activeNotifications.isEmpty
          ? _buildEmptyNotifications()
          : _buildActiveNotificationsList(),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
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
            'No Active Notifications',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveNotificationsList() {
    return ListView.builder(
      itemCount: activeNotifications.length,
      itemBuilder: (context, index) {
        var notification = activeNotifications[index];
        return Dismissible(
          key: ValueKey(notification.id),
          background: Container(color: Colors.white),
          onDismissed: (direction) async {
            if (notification.id != null) {
              await _clearNotification(notification.id!);
            }
          },
          child: Card(
            elevation: 2.0,
            color: Color(0xFF0D47A1),
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: Colors.white,
              ),
              title: Text(notification.title ?? 'No Title', style: GoogleFonts.poppins(color: Colors.white)),
              subtitle: Text(notification.body ?? 'No Details', style: GoogleFonts.poppins(color: Colors.white)),
              trailing: IconButton(
                icon: Icon(Icons.clear, color: Colors.white),
                onPressed: () async {
                  if (notification.id != null) {
                    await _clearNotification(notification.id!);
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}