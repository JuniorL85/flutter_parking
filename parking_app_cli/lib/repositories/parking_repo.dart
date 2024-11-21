import 'dart:convert';

import '../logic/set_main.dart';
import 'parking_space_repo.dart';
import 'vehicle_repo.dart';
import 'package:cli_shared/cli_shared.dart';

import 'package:http/http.dart' as http;

class ParkingRepository extends SetMain {
  ParkingRepository._privateConstructor();

  static final instance = ParkingRepository._privateConstructor();

  String host = 'http://localhost';
  String port = '8080';
  String resource = 'parkings';

  final VehicleRepository vehicleRepository = VehicleRepository.instance;
  final ParkingSpaceRepository parkingSpaceRepository =
      ParkingSpaceRepository.instance;

  Future<dynamic> addParking(Parking parking) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parking.serialize(parking)));

    return response;
  }

  Future<dynamic> getAllParkings() async {
    final uri = Uri.parse('$host:$port/$resource');

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    final json = jsonDecode(response.body);

    return (json as List)
        .map((parkings) => Parking.fromJson(parkings))
        .toList();
  }

  Future<Parking> getParkingById(int id) async {
    final uri = Uri.parse('$host:$port/$resource/$id');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return Parking.fromJson(json);
  }

  Future<dynamic> updateParkings(Parking parking) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parking.serialize(parking)));

    return response;
  }

  Future<dynamic> deleteParkings(Parking parking) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.delete(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parking.serialize(parking)));

    return response;
  }
}
