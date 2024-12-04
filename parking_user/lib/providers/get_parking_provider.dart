import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/providers/get_vehicle_provider.dart';
import 'package:provider/provider.dart';

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

  findActiveParking(BuildContext context) async {
    var parkingList = await context.read<GetParking>().getAllParkings();

    if (context.mounted) {
      Person person = context.read<GetPerson>().person;
      List<Vehicle> list = await context.read<GetVehicle>().getAllVehicles();
      var vehicleList = list
          .where((vehicle) =>
              vehicle.owner!.socialSecurityNumber ==
              person.socialSecurityNumber)
          .toList();

      final foundActiveParking = parkingList.indexWhere(
        (activeParking) => (vehicleList.any((v) =>
                v.regNr.toUpperCase() ==
                activeParking.vehicle!.regNr.toUpperCase()) &&
            activeParking.endTime.microsecondsSinceEpoch >
                DateTime.now().microsecondsSinceEpoch),
      );

      return foundActiveParking;
    }
  }
}
