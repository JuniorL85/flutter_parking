part of 'parking_spaces_bloc.dart';

sealed class ParkingSpacesState {}

class ParkingSpacesInitial extends ParkingSpacesState {
  List<Object?> get parkingSpaces => [];
}

class ParkingSpacesLoading extends ParkingSpacesState {
  List<Object?> get parkingSpaces => [];
}

class ParkingSpacesLoaded extends ParkingSpacesState {
  final List<ParkingSpace> parkingSpaces;

  ParkingSpacesLoaded({required this.parkingSpaces});
}

class ParkingSpacesError extends ParkingSpacesState {
  final String message;

  ParkingSpacesError({required this.message});

  List<Object?> get props => [message];
}
