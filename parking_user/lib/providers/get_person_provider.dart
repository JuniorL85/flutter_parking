import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class GetPerson extends ChangeNotifier {
  Person? _person;
  List<Person> _personList = [];

  Future<void> getPerson(int id) async {
    _person = await PersonRepository.instance.getPersonById(id);
    notifyListeners();
  }

  Person get person =>
      _person != null ? _person! : Person(name: '', socialSecurityNumber: '');

  Future<List<Person>> getAllPersons() async {
    _personList = await PersonRepository.instance.getAllPersons();
    return _personList;
  }

  List<Person> get personList => _personList;
  @override
  notifyListeners();
}
