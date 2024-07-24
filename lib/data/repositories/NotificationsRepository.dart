import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/AppNotification.dart';

class NotificationsRepository {
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

  Future<List<AppNotification>> getNotificationsFromFirebase() async {
    var querySnapshot = await notificationsCollection.get();

    return querySnapshot.docs
        .map((doc) => AppNotification.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
