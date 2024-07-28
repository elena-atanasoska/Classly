import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../application/services/ReservationService.dart';
import '../../domain/models/CalendarEvent.dart';
import '../../domain/models/Seat.dart';
import '../../application/services/AuthService.dart';
import '../../application/services/UserService.dart';

class ReserveSeatScreen extends StatefulWidget {
  final CalendarEvent event;

  const ReserveSeatScreen({Key? key, required this.event}) : super(key: key);

  @override
  _ReserveSeatScreenState createState() => _ReserveSeatScreenState();
}

class _ReserveSeatScreenState extends State<ReserveSeatScreen> {
  Seat? selectedSeat;
  final ReservationService reservationService = ReservationService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    selectedSeat = null;
  }

  void _selectSeat(Seat seat) {
    setState(() {
      selectedSeat = seat;
    });
  }

  Future<void> _reserveSeat() async {
    final user = await _authService.getCurrentUser();
    if (selectedSeat == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a seat and ensure you are logged in.'),
        ),
      );
      return;
    }

    bool alreadyReserved =
        await reservationService.checkReservation(user.uid, widget.event.id);

    if (alreadyReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already reserved a seat for this event.'),
        ),
      );
      return;
    }

    await reservationService.reserveSeat(
        user.uid, widget.event.id, selectedSeat!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seat reserved successfully!'),
      ),
    );

    Navigator.pop(context, true); // Pass result back to the EventScreen
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.event.room.columns,
                    childAspectRatio: 1, // Adjusted to make the seats taller
                  ),
                  itemCount: widget.event.room.rows * widget.event.room.columns,
                  itemBuilder: (context, index) {
                    int row = index ~/ widget.event.room.columns;
                    int column = index % widget.event.room.columns;
                    Seat seat = widget.event.room.seats[row][column];
                    bool isSelected = selectedSeat == seat;

                    return GestureDetector(
                      onTap: seat.isFree
                          ? () {
                              _selectSeat(seat);
                              setState(() {
                                selectedSeat = isSelected ? null : seat;
                              });
                            }
                          : null,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                        width: 20,
                        // Adjust this value to make the container narrower
                        height: 40,
                        // Adjust this value to make the container taller
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : (seat.isFree ? Colors.grey : Colors.black),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
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
              onPressed: selectedSeat != null ? _reserveSeat : null,
              child: const Text('Reserve seat'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    selectedSeat != null ? Colors.blue : Colors.grey,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Class details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.event.course.courseFullName} at ${DateFormat('HH:mm').format(widget.event.startTime)} - ${DateFormat('HH:mm').format(widget.event.endTime)} on ${DateFormat('d MMMM yyyy').format(widget.event.startTime)}',
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
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(13),
              bottomRight: Radius.circular(13),
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
          ),

        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }
}
