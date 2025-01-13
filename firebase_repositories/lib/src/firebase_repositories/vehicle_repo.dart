import 'dart:convert';
import 'dart:io';

import 'package:cli_shared/cli_shared.dart';

class VehicleRepository {
  VehicleRepository._privateConstructor();

  static final instance = VehicleRepository._privateConstructor();

  String host = Platform.isAndroid ? 'http://10.0.2.2' : 'http://localhost';
  String port = '8080';
  String resource = 'vehicles';

  Future<dynamic> addVehicle(Vehicle vehicle) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.serialize(vehicle)));

    return response;
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final uri = Uri.parse('$host:$port/$resource');

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    final json = jsonDecode(response.body);

    return (json as List).map((vehicle) => Vehicle.fromJson(vehicle)).toList();
  }

  Future<Vehicle> getVehicleById(String id) async {
    final uri = Uri.parse('$host:$port/$resource/$id');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return Vehicle.fromJson(json);
  }

  Future<dynamic> updateVehicles(Vehicle vehicle) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.serialize(vehicle)));

    return response;
  }

  Future<dynamic> deleteVehicle(Vehicle vehicle) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.delete(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.serialize(vehicle)));

    return response;
  }
}
