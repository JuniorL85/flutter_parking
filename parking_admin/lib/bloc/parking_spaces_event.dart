part of 'parking_spaces_bloc.dart';

sealed class ParkingSpacesEvent {}

class LoadParkingSpaces extends ParkingSpacesEvent {}

class CreateParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;

  CreateParkingSpace({required this.parkingSpace});
}

class DeleteParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;

  DeleteParkingSpace({required this.parkingSpace});
}
