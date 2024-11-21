import 'dart:convert';
import 'dart:io';

import 'package:cli_shared/cli_shared.dart';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:http/testing.dart';

void main() {
  final port = '8080';
  final host = 'http://0.0.0.0:$port';
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {'PORT': port},
    );
    // Wait for server to start and print to stdout.
    await p.stdout.first;
  });

  tearDown(() => p.kill());

  final personData = [
    {
      "id": 1,
      "name": "hej hej",
      "socialSecurityNumber": "121212121212",
    },
    {
      "id": 3,
      "name": "Jag jag",
      "socialSecurityNumber": "141414141414",
    }
  ];

  final vehicleData = [
    {
      "id": 1,
      "regNr": "GDO333",
      "vehicleType": "Car",
      "owner": Person(name: 'hej hej', socialSecurityNumber: '121212121212'),
    },
    {
      "id": 2,
      "regNr": "GDO444",
      "vehicleType": "Car",
      "owner": Person(name: 'Jag jag', socialSecurityNumber: '141414141414'),
    }
  ];

  final parkingSpaceData = [
    {
      "id": 1,
      "address": "Östergatan 22, 555 66 Göteborg",
      "pricePerHour": 21,
    },
    {
      "id": 2,
      "address": "Testgatan 11, 111 22 Örebro",
      "pricePerHour": 15,
    },
  ];

  final parkingData = [
    {
      "id": 1,
      "vehicle": Vehicle(regNr: 'GDO333', vehicleType: 'Car'),
      "parkingSpace": ParkingSpace(
          address: 'Östergatan 22, 555 66 Göteborg', pricePerHour: 21),
      "startTime": "2021-01-12T13:57:10.705476",
      "endTime": "2021-01-12T14:57:10.705476"
    },
    {
      "id": 2,
      "vehicle": Vehicle(regNr: 'GDO444', vehicleType: 'Car'),
      "parkingSpace": ParkingSpace(
          address: 'Testgatan 11, 111 22 Örebro', pricePerHour: 15),
      "startTime": "2021-01-12T13:57:10.705476",
      "endTime": "2021-01-12T15:57:10.705476"
    },
  ];

  var client = MockClient((request) async {
    if (request.url == Uri.parse('$host/persons')) {
      return Response(jsonEncode(personData), 200, request: request);
    }
    if (request.url == Uri.parse('$host/persons/1')) {
      return Response(jsonEncode(personData[0]), 200, request: request);
    }
    if (request.url == Uri.parse('$host/vehicles')) {
      return Response(jsonEncode(vehicleData), 200, request: request);
    }
    if (request.url == Uri.parse('$host/vehicles/2')) {
      return Response(jsonEncode(vehicleData[1]), 200, request: request);
    }
    if (request.url == Uri.parse('$host/parkingSpaces')) {
      return Response(jsonEncode(parkingSpaceData), 200, request: request);
    }
    if (request.url == Uri.parse('$host/parkingSpaces/2')) {
      return Response(jsonEncode(parkingSpaceData[1]), 200, request: request);
    }
    if (request.url == Uri.parse('$host/parkings')) {
      return Response(jsonEncode(parkingData), 200, request: request);
    }
    if (request.url == Uri.parse('$host/parkings/2')) {
      return Response(jsonEncode(parkingData[1]), 200, request: request);
    }
    return Response('', 404);
  });
  test('Persons', () async {
    final response = await client.get(Uri.parse('$host/persons'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(personData));
  });

  test('getPersonById', () async {
    final response = await client.get(Uri.parse('$host/persons/1'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(personData[0]));
  });

  test('Vehicles', () async {
    final response = await client.get(Uri.parse('$host/vehicles'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(vehicleData));
  });

  test('getVehicleById', () async {
    final response = await client.get(Uri.parse('$host/vehicles/2'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(vehicleData[1]));
  });

  test('ParkingSpaces', () async {
    final response = await client.get(Uri.parse('$host/parkingSpaces'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(parkingSpaceData));
  });

  test('getParkingSpaceById', () async {
    final response = await client.get(Uri.parse('$host/parkingSpaces/2'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(parkingSpaceData[1]));
  });

  test('Parkings', () async {
    final response = await client.get(Uri.parse('$host/parkings'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(parkingData));
  });

  test('getParkingById', () async {
    final response = await client.get(Uri.parse('$host/parkings/2'));
    expect(response.statusCode, 200);
    expect(response.body, jsonEncode(parkingData[1]));
  });

  test('404', () async {
    final response = await client.get(Uri.parse('$host/foobar'));
    expect(response.statusCode, 404);
  });
}
