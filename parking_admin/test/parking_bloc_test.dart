import 'package:bloc_test/bloc_test.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_admin/bloc/parking_bloc.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class MockActiveParkingRepository extends Mock implements ParkingRepository {}

class FakeParkingSpace extends Fake implements ParkingSpace {}

void main() {
  group('ActiveParkingBloc', () {
    late ParkingRepository activeParkingRepository;

    setUp(() {
      activeParkingRepository = MockActiveParkingRepository();
    });

    setUpAll(() {
      registerFallbackValue(FakeParkingSpace());
    });

    ActiveParkingBloc buildBloc() {
      return ActiveParkingBloc(
          activeParkingRepository: activeParkingRepository);
    }

    group("Load activeParking", () {
      final existingActiveParking = [
        Parking(
          id: 1,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          parkingSpace:
              ParkingSpace(id: 1, address: 'Testadress 1', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG111',
              vehicleType: 'Car',
              owner:
                  Person(name: 'Namn1', socialSecurityNumber: '111111111111')),
        ),
        Parking(
          id: 2,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          parkingSpace:
              ParkingSpace(id: 2, address: 'Testadress 2', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG222',
              vehicleType: 'Car',
              owner:
                  Person(name: 'Namn2', socialSecurityNumber: '222222222222')),
        )
      ];

      blocTest<ActiveParkingBloc, ActiveParkingState>(
        "load parkingspaces test",
        setUp: () {
          when(() => activeParkingRepository.getAllParkings())
              .thenAnswer((_) async => existingActiveParking);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadActiveParkings()),
        expect: () => [
          ActiveParkingsLoading(),
          ActiveParkingsLoaded(activeParkings: existingActiveParking),
        ],
        verify: (_) {
          verify(() => activeParkingRepository.getAllParkings()).called(1);
        },
      );

      blocTest<ActiveParkingBloc, ActiveParkingState>(
        'emits [ActiveParkingError] when load fails',
        setUp: () {
          when(() => activeParkingRepository.getAllParkings())
              .thenThrow(Exception('Failed to load activeParking'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadActiveParkings()),
        expect: () => [
          ActiveParkingsLoading(),
          ActiveParkingsError(
              message: 'Exception: Failed to load activeParking'),
        ],
      );
    });
  });
}
