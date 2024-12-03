import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class GetPerson extends ChangeNotifier {
  Person? _person;
  Future<void> getPerson(int id) async {
    _person = await PersonRepository.instance.getPersonById(id);
  }

  Person get person => _person!;
}
