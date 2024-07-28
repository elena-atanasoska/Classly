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

    DocumentReference reservationRef =
        firestore.collection('reservations').doc();
    batch.set(reservationRef, {
      'userId': userId,
      'eventId': eventId,
      'seat': {
        'row': seat.row,
        'column': seat.column,
      },
    });

    DocumentReference eventRef =
        firestore.collection('calendarEvents').doc(eventId);
    DocumentSnapshot eventSnapshot = await eventRef.get();

    if (eventSnapshot.exists) {
      Map<String, dynamic>? data =
          eventSnapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Event data is null');
      }

      Map<String, dynamic>? roomData = data['room'] as Map<String, dynamic>?;
      if (roomData == null) {
        throw Exception('Room data is null');
      }

      List<dynamic>? seatsData = roomData['seats'] as List<dynamic>?;
      if (seatsData == null) {
        throw Exception('Seats data is null');
      }

      List<List<Seat>> seats = List.generate(
        roomData['rows'],
        (row) => List.generate(
          roomData['columns'],
          (column) {
            var seatMap = seatsData.firstWhere(
              (element) => element['row'] == row && element['column'] == column,
              orElse: () => {'row': row, 'column': column, 'isFree': true},
            );
            return Seat.fromMap(seatMap);
          },
        ),
      );

      if (seats[seat.row][seat.column].isFree) {
        seats[seat.row][seat.column].isFree = false;

        List<Map<String, dynamic>> updatedSeatsData =
            seats.expand((row) => row.map((seat) => seat.toMap())).toList();

        batch.update(eventRef, {
          'room.seats': updatedSeatsData,
        });
      } else {
        throw Exception('Seat is already reserved');
      }
    } else {
      throw Exception('Event not found');
    }

    await batch.commit();
  }

  Future<Seat?> getReservedSeat(String userId, String eventId) async {
    final querySnapshot = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final data = querySnapshot.docs.first.data();
      return Seat(
        row: data['seat']['row'],
        column: data['seat']['column'],
        isFree: false,
      );
    }
    return null;
  }

  Future<void> cancelReservation(String userId, String eventId) async {
    final querySnapshot = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .get();

    final batch = _firestore.batch();

    for (var doc in querySnapshot.docs) {
      final seatData = doc.data()['seat'];
      final row = seatData['row'];
      final column = seatData['column'];

      final eventRef = _firestore.collection('calendarEvents').doc(eventId);
      final eventSnapshot = await eventRef.get();
      if (eventSnapshot.exists) {
        Map<String, dynamic>? data =
            eventSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          Map<String, dynamic>? roomData =
              data['room'] as Map<String, dynamic>?;
          if (roomData != null) {
            List<dynamic>? seatsData = roomData['seats'] as List<dynamic>?;
            if (seatsData != null) {
              var seatMap = seatsData.firstWhere(
                (element) =>
                    element['row'] == row && element['column'] == column,
                orElse: () => null,
              );
              if (seatMap != null) {
                seatMap['isFree'] = true;

                List<Map<String, dynamic>> updatedSeatsData = seatsData
                    .map((seat) => seat as Map<String, dynamic>)
                    .toList();
                batch.update(eventRef, {
                  'room.seats': updatedSeatsData,
                });
              }
            }
          }
        }
      }

      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
