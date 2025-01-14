import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final ParkingRepository parkingRepository;
  List<Parking> _parkingList = [];

  ParkingBloc({required this.parkingRepository}) : super(ParkingInitial()) {
    // on<LoadParkings>((event, emit) async {
    //   await onLoadParkings(emit);
    // });

    on<LoadActiveParkings>((event, emit) async {
      await onLoadActiveParkings(emit);
    });

    on<LoadNonActiveParkings>((event, emit) async {
      await onLoadNonActiveParkings(emit);
    });

    on<DeleteParking>((event, emit) async {
      await onDeleteParking(emit, event.parking);
    });

    on<CreateParking>((event, emit) async {
      await onCreateParking(emit, event.parking);
    });

    on<UpdateParking>((event, emit) async {
      await onUpdateParking(emit, event.parking);
    });
  }

  // Future<void> onLoadParkings(Emitter<ParkingState> emit) async {
  //   emit(ParkingsLoading());
  //   try {
  //     _parkingList = await parkingRepository.getAllParkings();
  //     emit(ParkingsLoaded(parkings: _parkingList));
  //   } catch (e) {
  //     emit(ParkingsError(message: e.toString()));
  //   }
  // }

  Future<void> onLoadActiveParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      _parkingList = await parkingRepository.getAllParkings();

      List<Parking> activeParkings = _parkingList
          .where(
            (activeParking) => (activeParking.endTime.microsecondsSinceEpoch >
                DateTime.now().microsecondsSinceEpoch),
          )
          .toList();
      emit(ActiveParkingsLoaded(parkings: activeParkings));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  Future<void> onLoadNonActiveParkings(Emitter<ParkingState> emit) async {
    emit(ParkingsLoading());
    try {
      _parkingList = await parkingRepository.getAllParkings();

      List<Parking> nonActiveParkings = _parkingList
          .where((parking) => parking.endTime.isBefore(DateTime.now()))
          .toList();
      emit(ParkingsLoaded(parkings: nonActiveParkings));
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  onCreateParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      await parkingRepository.addParking(parking);

      add(LoadActiveParkings());
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  onUpdateParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      await parkingRepository.updateParkings(parking);

      add(LoadActiveParkings());
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  onDeleteParking(Emitter<ParkingState> emit, Parking parking) async {
    try {
      await parkingRepository.deleteParkings(parking);

      add(LoadActiveParkings());
    } catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }
}
