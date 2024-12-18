part of 'parking_spaces_bloc.dart';

sealed class ParkingSpacesEvent {}

class LoadParkingSpaces extends ParkingSpacesEvent {}

class DeleteParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;

  DeleteParkingSpace({required this.parkingSpace});
}
