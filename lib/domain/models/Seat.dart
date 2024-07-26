class Seat {
  final int row;
  final int column;
  bool isFree;

  Seat({
    required this.row,
    required this.column,
    this.isFree = true,
  });

  factory Seat.fromMap(Map<String, dynamic> map) {
    return Seat(
      row: map['row'],
      column: map['column'],
      isFree: map['isFree'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'row': row,
      'column': column,
      'isFree': isFree,
    };
  }
}