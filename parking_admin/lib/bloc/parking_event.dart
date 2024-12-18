part of 'parking_bloc.dart';

sealed class ParkingEvent {}

class LoadParkings extends ParkingEvent {}

class LoadActiveParkings extends ParkingEvent {}
