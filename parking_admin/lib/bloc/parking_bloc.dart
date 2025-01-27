import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  List<Parking> _parkingList = [];

  ParkingBloc() : super(ParkingInitial()) {
    on<LoadParkings>((event, emit) async {
      await onLoadParkings(emit);
    });
  }

  Future<void> onLoadParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      _parkingList = await ParkingRepository.parkingInstance.getAllParkings();
      emit(ParkingsLoaded(parkings: _parkingList));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }
}

class ActiveParkingBloc extends Bloc<ParkingEvent, ActiveParkingState> {
  final ParkingRepository activeParkingRepository;
  List<Parking> _parkingList = [];

  ActiveParkingBloc({required this.activeParkingRepository})
      : super(ActiveParkingInitial()) {
    on<LoadActiveParkings>((event, emit) async {
      await onLoadActiveParkings(emit);
    });
  }

  Future<void> onLoadActiveParkings(Emitter<ActiveParkingState> emit) async {
    emit(ActiveParkingsLoading());
    try {
      _parkingList = await activeParkingRepository.getAllParkings();

      List<Parking> activeParkings = _parkingList
          .where(
            (activeParking) => (activeParking.endTime.microsecondsSinceEpoch >
                DateTime.now().microsecondsSinceEpoch),
          )
          .toList();
      emit(ActiveParkingsLoaded(activeParkings: activeParkings));
    } catch (e) {
      emit(ActiveParkingsError(message: e.toString()));
    }
  }
}
