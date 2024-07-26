import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../application/services/AuthService.dart';
import '../../application/services/ReservationService.dart';
import '../../application/services/UserService.dart';
import '../../domain/models/CalendarEvent.dart';
import '../../domain/models/CustomUser.dart';
import '../../domain/models/Seat.dart';

class ReserveSeatScreen extends StatefulWidget {
  final CalendarEvent event;

  const ReserveSeatScreen({Key? key, required this.event}) : super(key: key);

  @override
  _ReserveSeatScreenState createState() => _ReserveSeatScreenState();
}

class _ReserveSeatScreenState extends State<ReserveSeatScreen> {
  late Seat? selectedSeat;
  CustomUser? _currentUser;
  final ReservationService reservationService = ReservationService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    selectedSeat = null;
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    User? user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {

        _currentUser = CustomUser.fromFirebaseUser(user);
      });
      _currentUser = CustomUser.fromFirebaseUser(user);
    }
  }

  void _selectSeat(Seat seat) {
    setState(() {
      selectedSeat = seat;
    });
  }

  Future<void> _reserveSeat() async {
    if (selectedSeat == null || _currentUser == null) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a seat and ensure you are logged in.'),
        ),
      );
      return;
    }

    // Check if the user has already reserved a seat for this event
    // This example assumes you have a function to check this

    bool alreadyReserved = await checkIfUserHasReservedSeat(
      widget.event.id,
      _currentUser!.uid,
    );

    if (alreadyReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have already reserved a seat for this event.'),
        ),
      );
      return;
    }

    // Reserve the seat in the database
    await reserveSeatInDatabase(
      eventId: widget.event.id,
      userId: _currentUser!.uid,
      seat: selectedSeat!,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Seat reserved successfully!'),
      ),
    );

    // Navigate back or show a success message
  }

  Future<bool> checkIfUserHasReservedSeat(String eventId, String userId) async {
    // Implement the logic to check if the user has already reserved a seat for the event
    // For example, you could query Firestore to see if there's an existing reservation
    return false;
  }

  Future<void> reserveSeatInDatabase({
    required String eventId,
    required String userId,
    required Seat seat,
  }) async {
    // Implement the logic to save the seat reservation to the database
    // For example, you could add a document to a "reservations" collection in Firestore
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve a Seat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room: ${widget.event.room.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.event.room.columns,
                  childAspectRatio: 1.5,
                ),
                itemCount: widget.event.room.rows * widget.event.room.columns,
                itemBuilder: (context, index) {
                  int row = index ~/ widget.event.room.columns;
                  int column = index % widget.event.room.columns;
                  Seat seat = widget.event.room.seats[row][column];
                  bool isSelected = selectedSeat == seat;

                  return GestureDetector(
                    onTap: () {
                      _selectSeat(seat);
                      setState(() {
                        selectedSeat = isSelected ? null : seat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue
                            : (seat.isFree ? Colors.grey : Colors.black),
                        border: Border.all(
                          color: seat.isFree ? Colors.grey : Colors.black,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${String.fromCharCode(65 + column)}${row + 1}',
                          style: TextStyle(
                            color: seat.isFree ? Colors.black : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              selectedSeat != null
                  ? 'Selected seat: ${String.fromCharCode(65 + selectedSeat!.column)}${selectedSeat!.row + 1}'
                  : 'No seat selected',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedSeat != null
                  ? () async {
                bool hasReserved = await reservationService.checkReservation(
                    _currentUser!.uid, widget.event.id);
                if (hasReserved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You have already reserved a seat for this event.'),
                    ),
                  );
                } else {
                  await reservationService.reserveSeat(
                    _currentUser!.uid,
                    widget.event.id,
                    selectedSeat!,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Seat reserved successfully!'),
                    ),
                  );
                }
              }
                  : null, // Disable button if no seat is selected
              child: const Text('Reserve seat'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: selectedSeat != null ? Colors.blue : Colors.grey, // Button color based on seat selection
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Class details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.event.course.courseName} at ${widget.event.startTime.hour}:${widget.event.startTime.minute} on ${widget.event.startTime.day} ${widget.event.startTime.month} ${widget.event.startTime.year}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildLegendItem(Colors.grey, 'Free'),
                const SizedBox(width: 10),
                _buildLegendItem(Colors.black, 'Busy'),
                const SizedBox(width: 10),
                _buildLegendItem(Colors.blue, 'Selected'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}

