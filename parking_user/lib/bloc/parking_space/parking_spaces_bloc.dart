import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';

part 'parking_spaces_event.dart';
part 'parking_spaces_state.dart';

class ParkingSpacesBloc extends Bloc<ParkingSpacesEvent, ParkingSpacesState> {
  final ParkingSpaceRepository parkingSpaceRepository;
  List<ParkingSpace> _parkingSpaceList = [];
  ParkingSpacesBloc({required this.parkingSpaceRepository})
      : super(ParkingSpacesInitial()) {
    on<LoadParkingSpaces>((event, emit) async {
      await onLoadParkingSpaces(emit);
    });
  }

  Future<void> onLoadParkingSpaces(Emitter<ParkingSpacesState> emit) async {
    emit(ParkingSpacesLoading());
    try {
      _parkingSpaceList = await parkingSpaceRepository.getAllParkingSpaces();
      emit(ParkingSpacesLoaded(parkingSpaces: _parkingSpaceList));
    } catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }
}
