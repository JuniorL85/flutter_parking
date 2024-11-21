import 'package:objectbox/objectbox.dart';

@Entity()
class ParkingSpace {
  ParkingSpace({
    required this.address,
    required this.pricePerHour,
    this.id = 0,
  });

  @Id()
  int id;
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
