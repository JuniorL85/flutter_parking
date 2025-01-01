part of 'parking_bloc.dart';

sealed class ParkingState extends Equatable {}

class ParkingInitial extends ParkingState {
  @override
  List<Object?> get props => [];
}

class ParkingsLoading extends ParkingState {
  @override
  List<Object?> get props => [];
}

class ParkingsLoaded extends ParkingState {
  final List<Parking> parkings;

  ParkingsLoaded({required this.parkings});

  @override
  List<Object?> get props => [parkings];
}

class ParkingsError extends ParkingState {
  final String message;

  ParkingsError({required this.message});

  List<Object?> get props => [message];
}

class ActiveParkingsLoaded extends ParkingState {
  final List<Parking> parkings;

  ActiveParkingsLoaded({required this.parkings});

  @override
  List<Object?> get props => [parkings];
}
