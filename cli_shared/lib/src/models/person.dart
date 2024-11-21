import 'package:objectbox/objectbox.dart';

@Entity()
class Person {
  Person({required this.name, required this.socialSecurityNumber, this.id = 0});

  @Id()
  int id;
  String name;
  String socialSecurityNumber;

  Person deserialize(Map<String, dynamic> json) => Person.fromJson(json);

  Map<String, dynamic> serialize(item) => toJson();

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      socialSecurityNumber: json['socialSecurityNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'socialSecurityNumber': socialSecurityNumber,
      };
}
