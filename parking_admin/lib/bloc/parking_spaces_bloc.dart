import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'parking_spaces_event.dart';
part 'parking_spaces_state.dart';

class ParkingSpacesBloc extends Bloc<ParkingSpacesEvent, ParkingSpacesState> {
  ParkingSpacesBloc() : super(ParkingSpacesInitial()) {
    on<ParkingSpacesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
