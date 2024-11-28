import 'dart:convert';
import 'dart:io';

import '../logic/set_main.dart';
import 'package:http/http.dart' as http;
import 'package:cli_shared/cli_shared.dart';

class ParkingSpaceRepository extends SetMain {
  ParkingSpaceRepository._privateConstructor();

  static final instance = ParkingSpaceRepository._privateConstructor();

  String host = Platform.isAndroid ? 'http://10.0.2.2' : 'http://localhost';
  String port = '8080';
  String resource = 'parkingSpaces';

  Future<dynamic> addParkingSpace(ParkingSpace parkingSpace) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parkingSpace.serialize(parkingSpace)));

    return response;
  }

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    final uri = Uri.parse('$host:$port/$resource');

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    final json = jsonDecode(response.body);

    return (json as List)
        .map((parkingSpaces) => ParkingSpace.fromJson(parkingSpaces))
        .toList();
  }

  Future<ParkingSpace> getParkingSpaceById(int id) async {
    final uri = Uri.parse('$host:$port/$resource/$id');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return ParkingSpace.fromJson(json);
  }

  Future<dynamic> updateParkingSpace(ParkingSpace parkingSpace) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parkingSpace.serialize(parkingSpace)));

    return response;
  }

  Future<dynamic> deleteParkingSpace(ParkingSpace parkingSpace) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.delete(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parkingSpace.serialize(parkingSpace)));

    return response;
  }
}
