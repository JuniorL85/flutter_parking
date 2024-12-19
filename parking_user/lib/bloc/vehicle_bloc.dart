import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  List<Vehicle> _vehicleList = [];
  VehicleBloc() : super(VehiclesInitial()) {
    on<LoadVehicles>((event, emit) async {
      await onLoadVehicles(emit);
    });

    on<LoadVehiclesByPerson>((event, emit) async {
      await onLoadVehiclesByPerson(emit, event.person);
    });

    on<DeleteVehicles>((event, emit) async {
      await onDeleteVehicle(emit, event.vehicle);
    });

    on<CreateVehicle>((event, emit) async {
      await onCreateVehicle(emit, event.vehicle);
    });

    on<UpdateVehicle>((event, emit) async {
      await onUpdateVehicle(emit, event.vehicle);
    });
  }

  Future<void> onLoadVehicles(Emitter<VehicleState> emit) async {
    emit(VehiclesLoading());
    try {
      _vehicleList = await VehicleRepository.instance.getAllVehicles();
      emit(VehiclesLoaded(vehicles: _vehicleList));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> onLoadVehiclesByPerson(
      Emitter<VehicleState> emit, Person person) async {
    emit(VehiclesLoading());
    try {
      _vehicleList = await VehicleRepository.instance.getAllVehicles();
      final vehicleListByPerson = _vehicleList
          .where((vehicle) =>
              vehicle.owner!.socialSecurityNumber ==
              person.socialSecurityNumber)
          .toList();
      emit(VehiclesLoaded(vehicles: vehicleListByPerson));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  onCreateVehicle(Emitter<VehicleState> emit, Vehicle vehicle) async {
    try {
      await VehicleRepository.instance.addVehicle(Vehicle(
          regNr: vehicle.regNr,
          vehicleType: vehicle.vehicleType,
          owner: vehicle.owner));

      add(LoadVehiclesByPerson(person: vehicle.owner!));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  onUpdateVehicle(Emitter<VehicleState> emit, Vehicle vehicle) async {
    try {
      await VehicleRepository.instance.updateVehicles(Vehicle(
          id: vehicle.id,
          regNr: vehicle.regNr,
          vehicleType: vehicle.vehicleType,
          owner: vehicle.owner));

      add(LoadVehiclesByPerson(person: vehicle.owner!));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  onDeleteVehicle(Emitter<VehicleState> emit, Vehicle vehicle) async {
    try {
      await VehicleRepository.instance.deleteVehicle(Vehicle(
          id: vehicle.id,
          regNr: vehicle.regNr,
          vehicleType: vehicle.vehicleType,
          owner: vehicle.owner));

      add(LoadVehiclesByPerson(person: vehicle.owner!));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }
}
