import 'package:cli_server/server_config.dart';
import 'package:cli_shared/cli_shared.dart';

class VehicleRepository {
  VehicleRepository._privateConstructor();

  static final instance = VehicleRepository._privateConstructor();

  Box<Vehicle> vehicleList = ServerConfig.instance.store.box<Vehicle>();

  Future<Vehicle?> addVehicle(Vehicle vehicle) async {
    vehicleList.put(vehicle, mode: PutMode.insert);
    return vehicle;
  }

  Future<List<Vehicle>> getAllVehicles() async {
    return vehicleList.getAll();
  }

  Future<Vehicle?> getVehicleById(int id) async {
    return vehicleList.get(id);
  }

  Future<Vehicle?> updateVehicles(Vehicle vehicle) async {
    vehicleList.put(vehicle, mode: PutMode.update);
    return vehicle;
  }

  Future<Vehicle?> deleteVehicle(Vehicle vehicle) async {
    Vehicle? vehicles = vehicleList.get(vehicle.id);

    if (vehicles != null) {
      vehicleList.remove(vehicle.id);
    }

    return vehicles;
  }
}
