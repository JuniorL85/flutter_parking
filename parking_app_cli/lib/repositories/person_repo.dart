import 'dart:convert';

import '../logic/set_main.dart';
import 'vehicle_repo.dart';
import 'package:http/http.dart' as http;
import 'package:cli_shared/cli_shared.dart';

class PersonRepository extends SetMain {
  PersonRepository._privateConstructor();

  static final instance = PersonRepository._privateConstructor();

  String host = 'http://localhost';
  String port = '8080';
  String resource = 'persons';

  final VehicleRepository vehicleRepository = VehicleRepository.instance;

  Future<dynamic> addPerson(Person person) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.serialize(person)));

    return response;
  }

  Future<dynamic> getAllPersons() async {
    final uri = Uri.parse('$host:$port/$resource');

    final response =
        await http.get(uri, headers: {'Content-Type': 'application/json'});

    final json = jsonDecode(response.body);

    return (json as List).map((person) => Person.fromJson(person)).toList();
  }

  Future<Person> getPersonById(int id) async {
    final uri = Uri.parse('$host:$port/$resource/$id');

    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final json = jsonDecode(response.body);

    return Person.fromJson(json);
  }

  Future<dynamic> updatePersons(Person person) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.serialize(person)));

    return response;
  }

  Future<dynamic> deletePerson(Person person) async {
    final uri = Uri.parse('$host:$port/$resource');

    final response = await http.delete(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(person.serialize(person)));

    return response;
  }
}
