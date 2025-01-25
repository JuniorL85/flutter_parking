part of 'parking_spaces_bloc.dart';

sealed class ParkingSpacesEvent {}

class SubscribeToParkingSpaces extends ParkingSpacesEvent {
  final String parkingSpaceId;

  SubscribeToParkingSpaces({required this.parkingSpaceId});
}

class LoadParkingSpaces extends ParkingSpacesEvent {}

class CreateParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;

  CreateParkingSpace({required this.parkingSpace});
}

class UpdateParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;

  UpdateParkingSpace({required this.parkingSpace});
}

class DeleteParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;

  DeleteParkingSpace({required this.parkingSpace});
}
