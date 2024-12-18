import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

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
      _parkingList = await ParkingRepository.instance.getAllParkings();
      emit(ParkingsLoaded(parkings: _parkingList));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }
}

class ActiveParkingBloc extends Bloc<ParkingEvent, ActiveParkingState> {
  List<Parking> _parkingList = [];

  ActiveParkingBloc() : super(ActiveParkingInitial()) {
    on<LoadActiveParkings>((event, emit) async {
      await onLoadActiveParkings(emit);
    });
  }

  Future<void> onLoadActiveParkings(Emitter<ActiveParkingState> emit) async {
    emit(ActiveParkingsLoading());
    try {
      _parkingList = await ParkingRepository.instance.getAllParkings();

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
