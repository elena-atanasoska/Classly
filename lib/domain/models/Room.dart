

class Room {
  final String id;
  final String name;
  final String building;
  final String floor;
  final List<int> seats;

  Room({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.seats,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      name: map['name'],
      building: map['building'],
      floor: map['floor'],
      seats: List<int>.from(map['seats']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'building': building,
      'floor': floor,
      'seats': seats,
    };
  }
}
