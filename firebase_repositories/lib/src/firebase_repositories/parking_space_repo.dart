import 'package:cli_shared/cli_shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpaceRepository {
  ParkingSpaceRepository._privateConstructor();

  static final parkingSpaceInstance =
      ParkingSpaceRepository._privateConstructor();

  final db = FirebaseFirestore.instance.collection('parkingSpaces');

  Future<ParkingSpace> addParkingSpace(ParkingSpace parkingSpace) async {
    await db.doc(parkingSpace.id).set(parkingSpace.toJson());

    return parkingSpace;
  }

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    final snapshots = await db.get();

    final docs = snapshots.docs;

    final jsons = docs.map((doc) {
      final json = doc.data();
      json["id"] = doc.id;

      return json;
    }).toList();

    return jsons
        .map((parkingSpaces) => ParkingSpace.fromJson(parkingSpaces))
        .toList();
  }

  Future<ParkingSpace> getParkingSpaceById(String id) async {
    final snapshot = await db.doc(id).get();

    final json = snapshot.data();

    if (json == null) {
      throw Exception("ParkingSpace with id $id not found");
    }

    json["id"] = snapshot.id;

    return ParkingSpace.fromJson(json);
  }

  Future<ParkingSpace> updateParkingSpace(ParkingSpace parkingSpace) async {
    await db.doc(parkingSpace.id).set(parkingSpace.toJson());

    return parkingSpace;
  }

  Future<ParkingSpace> deleteParkingSpace(ParkingSpace parkingSpace) async {
    final parkingSpaceById = await getParkingSpaceById(parkingSpace.id);

    await db.doc(parkingSpace.id).delete();

    return parkingSpaceById;
  }

  Stream<List<ParkingSpace>> userItemsStream(String parkingSpaceId) {
    return db
        .where("creatorId", isEqualTo: parkingSpaceId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs;
      return docs.map((doc) => ParkingSpace.fromJson(doc.data())).toList();
    });
  }
}
