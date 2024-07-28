import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/Room.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addRoom(Room room) async {
    try {
      await _db.collection('rooms').doc(room.id).set(room.toMap());
    } catch (error) {
      print('Error adding room: $error');
      throw error;
    }
  }

  Future<List<Room>> getAvailableRooms() async {
    try {
      QuerySnapshot snapshot = await _db.collection('rooms').get();
      return snapshot.docs.map((doc) {
        return Room.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      print('Error fetching rooms: $error');
      throw error;
    }
  }
}
