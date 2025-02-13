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

    on<DeleteParkingSpace>((event, emit) async {
      await onDeleteParkingSpace(emit, event.parkingSpace);
    });

    on<CreateParkingSpace>((event, emit) async {
      await onCreateParkingSpace(emit, event.parkingSpace);
    });

    on<UpdateParkingSpace>((event, emit) async {
      await onUpdateParkingSpace(emit, event.parkingSpace);
    });

    on<SubscribeToParkingSpaces>((event, emit) async {
      return emit
          .onEach(parkingSpaceRepository.userItemsStream(event.parkingSpaceId),
              onData: (parkingSpaces) {
        return emit(ParkingSpacesLoaded(parkingSpaces: parkingSpaces));
      });
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

  onCreateParkingSpace(
      Emitter<ParkingSpacesState> emit, ParkingSpace parkingSpace) async {
    try {
      await parkingSpaceRepository.addParkingSpace(ParkingSpace(
        creatorId: parkingSpace.creatorId,
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
    try {
      await parkingSpaceRepository.updateParkingSpace(ParkingSpace(
        id: parkingSpace.id,
        creatorId: parkingSpace.creatorId,
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
    try {
      await parkingSpaceRepository.deleteParkingSpace(ParkingSpace(
        id: parkingSpace.id,
        creatorId: parkingSpace.creatorId,
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
