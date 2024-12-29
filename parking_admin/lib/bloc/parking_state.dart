part of 'parking_bloc.dart';

abstract class ParkingState {}

abstract class ActiveParkingState extends Equatable {}

class ParkingInitial extends ParkingState {
  List<Object?> get parkings => [];
}

class ParkingsLoading extends ParkingState {
  List<Object?> get parkings => [];
}

class ParkingsLoaded extends ParkingState {
  final List<Parking> parkings;

  ParkingsLoaded({required this.parkings});
}

class ParkingsError extends ParkingState {
  final String message;

  ParkingsError({required this.message});

  List<Object?> get props => [message];
}

class ActiveParkingsLoading extends ActiveParkingState {
  @override
  List<Object?> get props => [];
}

class ActiveParkingInitial extends ActiveParkingState {
  @override
  List<Object?> get props => [];
}

class ActiveParkingsLoaded extends ActiveParkingState {
  final List<Parking> activeParkings;

  ActiveParkingsLoaded({required this.activeParkings});

  @override
  List<Object?> get props => [activeParkings];
}

class ActiveParkingsError extends ActiveParkingState {
  final String message;

  ActiveParkingsError({required this.message});

  @override
  List<Object?> get props => [message];
}
