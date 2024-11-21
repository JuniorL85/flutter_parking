import 'dart:convert';

import 'package:cli_server/repositories/vehicle_repo.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

const _jsonHeaders = {
  'Content-Type': 'application/json',
};

final vehicleRepo = VehicleRepository.instance;

Future<Response> getAllVehicles(Request req) async {
  final vehicles = await vehicleRepo.getAllVehicles();

  final vehiclePayload = vehicles.map((p) => p.toJson()).toList();
  return Response.ok(
    jsonEncode(vehiclePayload),
    headers: _jsonHeaders,
  );
}

Future<Response> getVehicleById(Request req) async {
  var id = req.params["id"];

  if (id != null) {
    int? intId = int.tryParse(id);

    if (intId != null) {
      Vehicle? vehicle = await vehicleRepo.getVehicleById(intId);
      return Response.ok(
        jsonEncode(vehicle),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
  return Response.notFound('Vehicle with id: $id not found.....');
}

Future<Response> createVehicle(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final vehicle = Vehicle.fromJson(json);

  final vehiclePayload = await vehicleRepo.addVehicle(vehicle);

  return Response.ok(
    jsonEncode(vehiclePayload),
    headers: _jsonHeaders,
  );
}

Future<Response> updateVehicle(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final vehicle = Vehicle.fromJson(json);

  final vehiclePayload = await vehicleRepo.updateVehicles(vehicle);

  return Response.ok(
    jsonEncode(vehiclePayload),
    headers: _jsonHeaders,
  );
}

Future<Response> deleteVehicle(Request req) async {
  final data = await req.readAsString();
  final json = jsonDecode(data);
  final vehicle = Vehicle.fromJson(json);

  final vehiclePayload = await vehicleRepo.deleteVehicle(vehicle);

  return Response.ok(
    jsonEncode(vehiclePayload),
    headers: _jsonHeaders,
  );
}
