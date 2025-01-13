import 'dart:convert';
import 'dart:io';

import 'parking_space_repo.dart';
import 'vehicle_repo.dart';
import 'package:cli_shared/cli_shared.dart';

class ParkingRepository {
  ParkingRepository._privateConstructor();

  static final instance = ParkingRepository._privateConstructor();

  String host = Platform.isAndroid ? 'http://10.0.2.2' : 'http://localhost';
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

  Future<List<Parking>> getAllParkings() async {
    final uri = Uri.parse('$host:$port/$resource');

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    final json = jsonDecode(response.body);

    return (json as List)
        .map((parkings) => Parking.fromJson(parkings))
        .toList();
  }

  Future<Parking> getParkingById(String id) async {
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
