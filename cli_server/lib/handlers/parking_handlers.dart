import 'dart:convert';

import 'package:cli_server/repositories/parking_repo.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

const _jsonHeaders = {
  'Content-Type': 'application/json',
};

final parkingRepo = ParkingRepository.instance;

Future<Response> getAllParkings(Request req) async {
  final parkings = await parkingRepo.getAllParkings();

  final parkingPayload = parkings.map((p) => p.toJson()).toList();
  return Response.ok(
    jsonEncode(parkingPayload),
    headers: _jsonHeaders,
  );
}

Future<Response> getParkingById(Request req) async {
  var id = req.params["id"];

  if (id != null) {
    int? intId = int.tryParse(id);

    if (intId != null) {
      Parking? parking = await parkingRepo.getParkingById(intId);
      return Response.ok(
        jsonEncode(parking),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
  return Response.notFound('Parking with id: $id not found....');
}

Future<Response> createParking(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final parking = Parking.fromJson(json);

  final parkingPayload = await parkingRepo.addParking(parking);

  return Response.ok(
    jsonEncode(parkingPayload),
    headers: _jsonHeaders,
  );
}

Future<Response> updateParking(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final parking = Parking.fromJson(json);

  final parkingPayload = await parkingRepo.updateParkings(parking);

  return Response.ok(
    jsonEncode(parkingPayload),
    headers: _jsonHeaders,
  );
}

Future<Response> deleteParking(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final parking = Parking.fromJson(json);

  final payload = await parkingRepo.deleteParkings(parking);

  return Response.ok(
    jsonEncode(payload),
    headers: _jsonHeaders,
  );
}
