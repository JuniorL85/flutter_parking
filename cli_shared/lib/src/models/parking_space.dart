import 'package:uuid/uuid.dart';

class ParkingSpace {
  ParkingSpace({
    required this.address,
    required this.pricePerHour,
    required this.creatorId,
    String? id,
  }) : id = id ?? Uuid().v4();

  final String id;
  final String creatorId;
  final String address;
  final int pricePerHour;

  ParkingSpace deserialize(Map<String, dynamic> json) =>
      ParkingSpace.fromJson(json);

  Map<String, dynamic> serialize(item) => toJson();

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      creatorId: json['creatorId'],
      address: json['address'],
      pricePerHour: json['pricePerHour'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'creatorId': creatorId,
        'address': address,
        'pricePerHour': pricePerHour,
      };
}
