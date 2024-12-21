import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class GetParking extends ChangeNotifier {
  Parking? _parking;
  List<Parking> _parkingList = [];

  Parking get parking => _parking!;

  Future<List<Parking>> getAllParkings() async {
    _parkingList = await ParkingRepository.instance.getAllParkings();
    return _parkingList;
  }

  List<Parking> get parkingList => _parkingList;
  @override
  notifyListeners();
}
