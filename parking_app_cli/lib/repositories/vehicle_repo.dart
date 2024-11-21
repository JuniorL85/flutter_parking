import 'dart:convert';

import '../logic/set_main.dart';
import 'package:http/http.dart' as http;
import 'package:cli_shared/cli_shared.dart';

class VehicleRepository extends SetMain {
  VehicleRepository._privateConstructor();

  static final instance = VehicleRepository._privateConstructor();

  String host = 'http://localhost';
  String port = '8080';
  String resource = 'vehicles';

  Future<dynamic> addVehicle(Vehicle vehicle) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.serialize(vehicle)));

    return response;
  }

  Future<dynamic> getAllVehicles() async {
    final uri = Uri.parse('$host:$port/$resource');

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    final json = jsonDecode(response.body);

    return (json as List).map((vehicle) => Vehicle.fromJson(vehicle)).toList();
  }

  Future<Vehicle> getVehicleById(int id) async {
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
