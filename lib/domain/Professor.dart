import 'package:uuid/uuid.dart';

class Professor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  Professor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      id: json['id'] ?? _generateId(),
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  static String _generateId() {
    final uuid = Uuid();
    return uuid.v4();
  }
}
