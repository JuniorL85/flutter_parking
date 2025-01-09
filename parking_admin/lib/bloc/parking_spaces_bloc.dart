import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

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

    on<DeleteParkingSpace>((event, emit) async {
      await onDeleteParkingSpace(emit, event.parkingSpace);
    });

    on<CreateParkingSpace>((event, emit) async {
      await onCreateParkingSpace(emit, event.parkingSpace);
    });

    on<UpdateParkingSpace>((event, emit) async {
      await onUpdateParkingSpace(emit, event.parkingSpace);
    });
  }

  Future<void> onLoadParkingSpaces(Emitter<ParkingSpacesState> emit) async {
    emit(ParkingSpacesLoading());
    await Future.delayed(const Duration(seconds: 2));
    try {
      _parkingSpaceList = await parkingSpaceRepository.getAllParkingSpaces();
      emit(ParkingSpacesLoaded(parkingSpaces: _parkingSpaceList));
    } catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  onCreateParkingSpace(
      Emitter<ParkingSpacesState> emit, ParkingSpace parkingSpace) async {
    emit(ParkingSpacesLoading());
    await Future.delayed(const Duration(seconds: 2));
    try {
      await parkingSpaceRepository.addParkingSpace(ParkingSpace(
        address: parkingSpace.address,
        pricePerHour: parkingSpace.pricePerHour,
      ));

      final loadedParkingSpaces =
          await parkingSpaceRepository.getAllParkingSpaces();
      emit(ParkingSpacesLoaded(parkingSpaces: loadedParkingSpaces));
    } catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  onUpdateParkingSpace(
      Emitter<ParkingSpacesState> emit, ParkingSpace parkingSpace) async {
    emit(ParkingSpacesLoading());
    await Future.delayed(const Duration(seconds: 2));
    try {
      await parkingSpaceRepository.updateParkingSpace(ParkingSpace(
        id: parkingSpace.id,
        address: parkingSpace.address,
        pricePerHour: parkingSpace.pricePerHour,
      ));

      final loadedParkingSpaces =
          await parkingSpaceRepository.getAllParkingSpaces();
      emit(ParkingSpacesLoaded(parkingSpaces: loadedParkingSpaces));
    } catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  onDeleteParkingSpace(
      Emitter<ParkingSpacesState> emit, ParkingSpace parkingSpace) async {
    emit(ParkingSpacesLoading());
    await Future.delayed(const Duration(seconds: 2));
    try {
      await parkingSpaceRepository.deleteParkingSpace(ParkingSpace(
        id: parkingSpace.id,
        address: parkingSpace.address,
        pricePerHour: parkingSpace.pricePerHour,
      ));

      final loadedParkingSpaces =
          await parkingSpaceRepository.getAllParkingSpaces();
      emit(ParkingSpacesLoaded(parkingSpaces: loadedParkingSpaces));
    } catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }
}
