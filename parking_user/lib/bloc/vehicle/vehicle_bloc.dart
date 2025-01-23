import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;
  List<Vehicle> _vehicleList = [];
  VehicleBloc({required this.vehicleRepository}) : super(VehiclesInitial()) {
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

    on<UpdateVehicles>((event, emit) async {
      await onUpdateVehicle(emit, event.vehicle);
    });
  }

  Future<void> onLoadVehicles(Emitter<VehicleState> emit) async {
    emit(VehiclesLoading());
    _vehicleList = [];
    try {
      _vehicleList = await vehicleRepository.getAllVehicles();
      emit(VehiclesLoaded(vehicles: _vehicleList));
    } catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> onLoadVehiclesByPerson(
      Emitter<VehicleState> emit, Person person) async {
    emit(VehiclesLoading());
    _vehicleList = [];
    print(person.id);
    print(person.name);
    try {
      _vehicleList = await vehicleRepository.getAllVehicles();
      print('jag är ändå inne här också');
      final vehicleListByPerson = _vehicleList
          .where((vehicle) => vehicle.owner!.id == person.id)
          .toList();
      print(vehicleListByPerson.length);
      emit(VehiclesLoaded(vehicles: vehicleListByPerson));
    } catch (e) {
      print('i error $e');
      emit(VehiclesError(message: e.toString()));
    }
  }

  onCreateVehicle(Emitter<VehicleState> emit, Vehicle vehicle) async {
    try {
      await vehicleRepository.addVehicle(Vehicle(
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
      await vehicleRepository.updateVehicles(Vehicle(
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
      await vehicleRepository.deleteVehicle(Vehicle(
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
