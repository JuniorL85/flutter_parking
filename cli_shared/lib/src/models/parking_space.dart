import 'package:uuid/uuid.dart';

class ParkingSpace {
  ParkingSpace({
    required this.address,
    required this.pricePerHour,
    String? id,
  }) : id = id ?? Uuid().v4();

  final String id;
  final String address;
  final int pricePerHour;

  ParkingSpace deserialize(Map<String, dynamic> json) =>
      ParkingSpace.fromJson(json);

  Map<String, dynamic> serialize(item) => toJson();

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      address: json['address'],
      pricePerHour: json['pricePerHour'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'pricePerHour': pricePerHour,
      };
}
