import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/Seat.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkReservation(String userId, String eventId) async {
    final reservationSnapshot = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .get();

    return reservationSnapshot.docs.isNotEmpty;
  }

  Future<void> reserveSeat(String userId, String eventId, Seat seat) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Create a new reservation document
    DocumentReference reservationRef = firestore.collection('reservations').doc();
    batch.set(reservationRef, {
      'userId': userId,
      'eventId': eventId,
      'seat': {
        'row': seat.row,
        'column': seat.column,
      },
    });

    // Get the current state of the event document
    DocumentReference eventRef = firestore.collection('calendarEvents').doc(eventId);
    DocumentSnapshot eventSnapshot = await eventRef.get();

    if (eventSnapshot.exists) {
      Map<String, dynamic>? data = eventSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Event data is null');
      }

      // Safely access the 'room' field
      Map<String, dynamic>? roomData = data['room'] as Map<String, dynamic>?;
      if (roomData == null) {
        throw Exception('Room data is null');
      }

      // Handle 'seats' field as a list of maps
      List<dynamic>? seatsData = roomData['seats'] as List<dynamic>?;
      if (seatsData == null) {
        throw Exception('Seats data is null');
      }

      // Convert seat data to a 2D list of Seat objects
      List<List<Seat>> seats = List.generate(
        data['rows'],
            (row) => List.generate(
          data['columns'],
              (column) {
            var seatMap = seatsData.firstWhere(
                  (element) => element['row'] == row && element['column'] == column,
              orElse: () => {'row': row, 'column': column, 'isFree': true},
            );
            return Seat.fromMap(seatMap);
          },
        ),
      );

      // Update the specific seat
      if (seats[seat.row][seat.column].isFree) {
        seats[seat.row][seat.column].isFree = false;

        // Convert the updated 2D list back to a list of maps
        List<Map<String, dynamic>> updatedSeatsData = seats
            .expand((row) => row.map((seat) => seat.toMap()))
            .toList();

        // Update the entire 'seats' field
        batch.update(eventRef, {
          'room.seats': updatedSeatsData,
        });
      } else {
        throw Exception('Seat is already reserved');
      }
    } else {
      throw Exception('Event not found');
    }

    // Commit the batch
    await batch.commit();
  }

}

