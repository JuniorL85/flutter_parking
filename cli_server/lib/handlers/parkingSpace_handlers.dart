import 'dart:convert';

import 'package:cli_server/repositories/parking_space_repo.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

const _jsonHeaders = {
  'Content-Type': 'application/json',
};

final parkingSpaceRepo = ParkingSpaceRepository.instance;

Future<Response> getAllParkingSpaces(Request req) async {
  final parkingSpaces = await parkingSpaceRepo.getAllParkingSpaces();

  final payload = parkingSpaces.map((p) => p.toJson()).toList();
  return Response.ok(
    jsonEncode(payload),
    headers: _jsonHeaders,
  );
}

Future<Response> getParkingSpaceById(Request req) async {
  var id = req.params["id"];

  if (id != null) {
    int? intId = int.tryParse(id);

    if (intId != null) {
      ParkingSpace? parkingSpace =
          await parkingSpaceRepo.getParkingSpaceById(intId);
      return Response.ok(
        jsonEncode(parkingSpace),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
  return Response.notFound('Parkingspace with id: $id not found....');
}

Future<Response> createParkingSpace(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final parkingSpace = ParkingSpace.fromJson(json);

  final payload = await parkingSpaceRepo.addParkingSpace(parkingSpace);

  return Response.ok(
    jsonEncode(payload),
    headers: _jsonHeaders,
  );
}

Future<Response> updateParkingSpace(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final parkingSpace = ParkingSpace.fromJson(json);

  final payload = await parkingSpaceRepo.updateParkingSpace(parkingSpace);

  return Response.ok(
    jsonEncode(payload),
    headers: _jsonHeaders,
  );
}

Future<Response> deleteParkingSpace(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final parkingSpace = ParkingSpace.fromJson(json);

  final payload = await parkingSpaceRepo.deleteParkingSpace(parkingSpace);

  return Response.ok(
    jsonEncode(payload),
    headers: _jsonHeaders,
  );
}
