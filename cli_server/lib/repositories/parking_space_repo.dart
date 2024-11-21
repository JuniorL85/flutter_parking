import 'package:cli_server/server_config.dart';
import 'package:cli_shared/cli_shared.dart';

class ParkingSpaceRepository {
  ParkingSpaceRepository._privateConstructor();

  static final instance = ParkingSpaceRepository._privateConstructor();

  Box<ParkingSpace> parkingSpaceList =
      ServerConfig.instance.store.box<ParkingSpace>();

  Future<ParkingSpace> addParkingSpace(ParkingSpace parkingSpace) async {
    parkingSpaceList.put(parkingSpace, mode: PutMode.insert);
    return parkingSpace;
  }

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    return parkingSpaceList.getAll();
  }

  Future<ParkingSpace?> getParkingSpaceById(int id) async {
    return parkingSpaceList.get(id);
  }

  Future<ParkingSpace> updateParkingSpace(ParkingSpace parkingSpace) async {
    parkingSpaceList.put(parkingSpace, mode: PutMode.update);
    return parkingSpace;
  }

  Future<ParkingSpace> deleteParkingSpace(ParkingSpace parkingSpace) async {
    ParkingSpace? parkingSpaces = parkingSpaceList.get(parkingSpace.id);

    if (parkingSpaces != null) {
      parkingSpaceList.remove(parkingSpace.id);
    }

    return parkingSpace;
  }
}
