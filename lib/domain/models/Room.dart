import 'Seat.dart';

class Room {
  final String id;
  final String name;
  final String building;
  final String floor;
  final int rows;
  final int columns;
  late List<List<Seat>> seats;

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.rows,
    required this.columns,
  }) {
    seats = List.generate(
      rows,
          (row) => List.generate(
        columns,
            (column) => Seat(row: row, column: column),
      ),
    );
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    var rows = map['rows'];
    var columns = map['columns'];
    var seatsData = map['seats'] as List;

    var seats = List<List<Seat>>.generate(
      rows,
          (row) => List<Seat>.generate(
        columns,
            (column) {
          var seatMap = seatsData.firstWhere((element) =>
          element['row'] == row && element['column'] == column);
          return Seat.fromMap(seatMap);
        },
      ),
    );

    return Room(
      id: map['id'],
      name: map['name'],
      building: map['building'],
      floor: map['floor'],
      rows: rows,
      columns: columns,
    )..seats = seats;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'building': building,
      'floor': floor,
      'rows': rows,
      'columns': columns,
      'seats': seats.expand((row) => row.map((seat) => seat.toMap())).toList(),
    };
  }
}