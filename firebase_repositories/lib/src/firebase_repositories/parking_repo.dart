import 'package:cli_shared/cli_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingRepository {
  ParkingRepository._privateConstructor();

  static final parkingInstance = ParkingRepository._privateConstructor();

  final db = FirebaseFirestore.instance;

  Future<Parking> addParking(Parking parking) async {
    await db.collection("parkings").doc(parking.id).set(parking.toJson());

    return parking;
  }

  Future<List<Parking>> getAllParkings() async {
    final snapshots = await db.collection("parkings").get();

    final docs = snapshots.docs;

    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;

      return json;
    }).toList();

    return jsons.map((parkings) => Parking.fromJson(parkings)).toList();
  }

  Future<Parking> getParkingById(String id) async {
    final snapshot = await db.collection("parkings").doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      throw Exception("Parking with id $id not found");
    }

    json["id"] = snapshot.id;

    return Parking.fromJson(json);
  }

  Future<Parking> updateParkings(Parking parking) async {
    await db.collection("parkings").doc(parking.id).set(parking.toJson());

    return parking;
  }

  Future<Parking> deleteParkings(Parking parking) async {
    final parkingById = await getParkingById(parking.id);

    await db.collection("parkings").doc(parking.id).delete();

    return parkingById;
  }
}
