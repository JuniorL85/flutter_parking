part of 'vehicle_bloc.dart';

sealed class VehicleState extends Equatable {}

class VehiclesInitial extends VehicleState {
  @override
  List<Object?> get props => [];
}

class VehiclesLoading extends VehicleState {
  @override
  List<Object?> get props => [];
}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  VehiclesLoaded({required this.vehicles});

  @override
  List<Object?> get props => [vehicles];
}

class VehiclesError extends VehicleState {
  final String message;

  VehiclesError({required this.message});

  @override
  List<Object?> get props => [message];
}
