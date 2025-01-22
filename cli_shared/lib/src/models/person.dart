import 'package:uuid/uuid.dart';

class Person {
  Person({
    required this.name,
    required this.socialSecurityNumber,
    required this.email,
    String? id,
  }) : id = id ?? Uuid().v4();

  String id;
  String name;
  String socialSecurityNumber;
  String email;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Person && other.email == email && other.id == id;
  }

  @override
  int get hashCode => email.hashCode ^ id.hashCode;

  // Person deserialize(Map<String, dynamic> json) => Person.fromJson(json);

  // Map<String, dynamic> serialize(item) => toJson();

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      socialSecurityNumber: json['socialSecurityNumber'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'socialSecurityNumber': socialSecurityNumber,
        'email': email,
      };
}
