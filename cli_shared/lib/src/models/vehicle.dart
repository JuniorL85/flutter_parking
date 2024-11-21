import 'dart:convert';

import 'package:objectbox/objectbox.dart';

import 'person.dart';

@Entity()
class Vehicle {
  Vehicle({
    required this.regNr,
    required this.vehicleType,
    this.owner,
    this.id = 0,
  });

  @Id()
  int id;
  final String regNr;
  final String vehicleType;
  @Transient()
  Person? owner;

  String? get ownerInDb {
    if (owner == null) {
      return null;
    } else {
      return jsonEncode(owner!.toJson());
    }
  }

  set ownerInDb(String? json) {
    if (json == null) {
      owner = null;
      return;
    }
    var decoded = jsonDecode(json);

    if (decoded != null) {
      owner = Person.fromJson(decoded);
    } else {
      owner = null;
    }
  }

  Vehicle deserialize(Map<String, dynamic> json) => Vehicle.fromJson(json);

  Map<String, dynamic> serialize(item) => toJson();

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
        id: json['id'],
        regNr: json['regNr'],
        vehicleType: json['vehicleType'],
        owner: json['owner'] != null ? Person.fromJson(json['owner']) : null);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'regNr': regNr,
        'vehicleType': vehicleType,
        'owner': owner?.toJson()
      };
}
