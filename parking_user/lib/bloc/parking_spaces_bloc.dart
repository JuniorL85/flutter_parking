import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

part 'parking_spaces_event.dart';
part 'parking_spaces_state.dart';

class ParkingSpacesBloc extends Bloc<ParkingSpacesEvent, ParkingSpacesState> {
  List<ParkingSpace> _parkingSpaceList = [];
  ParkingSpacesBloc() : super(ParkingSpacesInitial()) {
    on<LoadParkingSpaces>((event, emit) async {
      await onLoadParkingSpaces(emit);
    });
  }

  Future<void> onLoadParkingSpaces(Emitter<ParkingSpacesState> emit) async {
    emit(ParkingSpacesLoading());
    try {
      _parkingSpaceList =
          await ParkingSpaceRepository.instance.getAllParkingSpaces();
      emit(ParkingSpacesLoaded(parkingSpaces: _parkingSpaceList));
    } catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }
}
