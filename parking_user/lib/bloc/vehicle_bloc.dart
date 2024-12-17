import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(VehicleInitial()) {
    on<VehicleEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
