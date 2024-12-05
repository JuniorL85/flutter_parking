import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class GetParking extends ChangeNotifier {
  Parking? _parking;
  List<Parking> _parkingList = [];

  Future<void> getParking(int id) async {
    _parking = await ParkingRepository.instance.getParkingById(id);
    notifyListeners();
  }

  Parking get parking => _parking!;

  Future<List<Parking>> getAllParkings() async {
    _parkingList = await ParkingRepository.instance.getAllParkings();
    return _parkingList;
  }

  List<Parking> get parkingList => _parkingList;
  @override
  notifyListeners();

  Future<List<Parking>> findActiveParking() async {
    var parkingList = await getAllParkings();

    List<Parking> activeParkings = parkingList
        .where(
          (activeParking) => (activeParking.endTime.microsecondsSinceEpoch >
              DateTime.now().microsecondsSinceEpoch),
        )
        .toList();

    return activeParkings;
  }
}
