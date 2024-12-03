import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class GetVehicle extends ChangeNotifier {
  Vehicle? _vehicle;
  List<Vehicle> _vehicleList = [];

  Future<void> getVehicle(int id) async {
    _vehicle = await VehicleRepository.instance.getVehicleById(id);
    notifyListeners();
  }

  Vehicle get vehicle => _vehicle!;

  Future<List<Vehicle>> getAllVehicles() async {
    _vehicleList = await VehicleRepository.instance.getAllVehicles();
    return _vehicleList;
  }

  List<Vehicle> get vehicleList => _vehicleList;
  @override
  notifyListeners();
}
