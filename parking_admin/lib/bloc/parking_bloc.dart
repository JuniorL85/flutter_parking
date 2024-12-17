import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  ParkingBloc() : super(ParkingInitial()) {
    on<ParkingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
