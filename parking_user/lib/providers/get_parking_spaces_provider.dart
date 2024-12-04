import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class GetParkingSpaces extends ChangeNotifier {
  ParkingSpace? _parkingSpace;
  List<ParkingSpace> _parkingSpaceList = [];

  Future<void> getParkingSpace(int id) async {
    _parkingSpace =
        await ParkingSpaceRepository.instance.getParkingSpaceById(id);
    notifyListeners();
  }

  ParkingSpace get parkingSpace => _parkingSpace!;

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    _parkingSpaceList =
        await ParkingSpaceRepository.instance.getAllParkingSpaces();
    return _parkingSpaceList;
  }

  List<ParkingSpace> get parkingSpaceList => _parkingSpaceList;
  @override
  notifyListeners();
}
