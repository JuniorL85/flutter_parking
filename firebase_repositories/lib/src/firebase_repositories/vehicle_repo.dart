import 'package:cli_shared/cli_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepository {
  VehicleRepository._privateConstructor();

  static final vehicleInstance = VehicleRepository._privateConstructor();

  final db = FirebaseFirestore.instance;

  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    await db.collection("vehicles").doc(vehicle.id).set(vehicle.toJson());

    return vehicle;
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final snapshots = await db.collection("vehicles").get();

    final docs = snapshots.docs;

    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;

      return json;
    }).toList();

    return jsons.map((vehicle) => Vehicle.fromJson(vehicle)).toList();
  }

  Future<Vehicle> getVehicleById(String id) async {
    final snapshot = await db.collection("vehicles").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      throw Exception("Vehicle with id $id not found");
    }

    json["id"] = snapshot.id;

    return Vehicle.fromJson(json);
  }

  Future<Vehicle> updateVehicles(Vehicle vehicle) async {
    await db.collection("vehicles").doc(vehicle.id).set(vehicle.toJson());

    return vehicle;
  }

  Future<Vehicle> deleteVehicle(Vehicle vehicle) async {
    final vehicleById = await getVehicleById(vehicle.id);

    await db.collection("vehicles").doc(vehicle.id).delete();

    return vehicleById;
  }
}
