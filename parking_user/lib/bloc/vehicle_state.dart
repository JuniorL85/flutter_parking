part of 'vehicle_bloc.dart';

sealed class VehicleState {}

class VehiclesInitial extends VehicleState {
  List<Object?> get vehicles => [];
}

class VehiclesLoading extends VehicleState {
  List<Object?> get vehicles => [];
}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  VehiclesLoaded({required this.vehicles});
}

class VehiclesError extends VehicleState {
  final String message;

  VehiclesError({required this.message});

  List<Object?> get props => [message];
}
