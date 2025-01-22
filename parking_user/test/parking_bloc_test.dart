import 'package:bloc_test/bloc_test.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/bloc/parking/parking_bloc.dart';

class MockParkingRepository extends Mock implements ParkingRepository {}

class FakeParking extends Fake implements Parking {}

void main() {
  group('ParkingBloc', () {
    late ParkingRepository parkingRepository;

    setUp(() {
      parkingRepository = MockParkingRepository();
    });

    setUpAll(() {
      registerFallbackValue(FakeParking());
    });

    ParkingBloc buildBloc() {
      return ParkingBloc(parkingRepository: parkingRepository);
    }

    group("Load active parkings", () {
      final existingParkings = [
        Parking(
          id: '1',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          parkingSpace:
              ParkingSpace(id: '1', address: 'Testadress 1', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG111',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn1',
                socialSecurityNumber: '111111111111',
                email: 'test@test1.se',
              )),
        ),
        Parking(
          id: '2',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          parkingSpace:
              ParkingSpace(id: '2', address: 'Testadress 2', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG222',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn2',
                socialSecurityNumber: '222222222222',
                email: 'test@test2.se',
              )),
        )
      ];

      blocTest<ParkingBloc, ParkingState>(
        "load active parkings test",
        setUp: () {
          when(() => parkingRepository.getAllParkings())
              .thenAnswer((_) async => existingParkings);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadActiveParkings()),
        expect: () => [
          ParkingsLoading(),
          ActiveParkingsLoaded(parkings: existingParkings),
        ],
        verify: (_) {
          verify(() => parkingRepository.getAllParkings()).called(1);
        },
      );

      blocTest<ParkingBloc, ParkingState>(
        'emits [ParkingError] when load active parkings fails',
        setUp: () {
          when(() => parkingRepository.getAllParkings())
              .thenThrow(Exception('Failed to load active parkings'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadActiveParkings()),
        expect: () => [
          ParkingsLoading(),
          ParkingsError(message: 'Exception: Failed to load active parkings'),
        ],
      );
    });

    group("Load non-active parkings", () {
      final existingParkings = [
        Parking(
          id: '1',
          startTime: DateTime.now().add(const Duration(hours: -2)),
          endTime: DateTime.now().add(const Duration(hours: -1)),
          parkingSpace:
              ParkingSpace(id: '1', address: 'Testadress 1', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG111',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn1',
                socialSecurityNumber: '111111111111',
                email: 'test@test1.se',
              )),
        ),
        Parking(
          id: '2',
          startTime: DateTime.now().add(const Duration(hours: -3)),
          endTime: DateTime.now().add(const Duration(hours: -2)),
          parkingSpace:
              ParkingSpace(id: '2', address: 'Testadress 2', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG222',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn2',
                socialSecurityNumber: '222222222222',
                email: 'test@test2.se',
              )),
        )
      ];

      blocTest<ParkingBloc, ParkingState>(
        "load non-active parkings test",
        setUp: () {
          when(() => parkingRepository.getAllParkings())
              .thenAnswer((_) async => existingParkings);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadNonActiveParkings()),
        expect: () => [
          ParkingsLoading(),
          ParkingsLoaded(parkings: existingParkings),
        ],
        verify: (_) {
          verify(() => parkingRepository.getAllParkings()).called(1);
        },
      );

      blocTest<ParkingBloc, ParkingState>(
        'emits [ParkingError] when load non-active parkings fails',
        setUp: () {
          when(() => parkingRepository.getAllParkings())
              .thenThrow(Exception('Failed to load non-active parkings'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadNonActiveParkings()),
        expect: () => [
          ParkingsLoading(),
          ParkingsError(
              message: 'Exception: Failed to load non-active parkings'),
        ],
      );
    });

    group("Create parkings", () {
      final newParking = Parking(
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        parkingSpace:
            ParkingSpace(id: '1', address: 'Testadress 3', pricePerHour: 10),
        vehicle: Vehicle(
            regNr: 'REG333',
            vehicleType: 'Car',
            owner: Person(
              name: 'Namn3',
              socialSecurityNumber: '333333333333',
              email: 'test@test3.se',
            )),
      );
      final existingParkings = [
        Parking(
          id: '1',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          parkingSpace:
              ParkingSpace(id: '1', address: 'Testadress 1', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG111',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn1',
                socialSecurityNumber: '111111111111',
                email: 'test@test1.se',
              )),
        ),
        Parking(
          id: '2',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          parkingSpace:
              ParkingSpace(id: '2', address: 'Testadress 2', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG222',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn2',
                socialSecurityNumber: '222222222222',
                email: 'test@test2.se',
              )),
        )
      ];

      blocTest<ParkingBloc, ParkingState>(
        "create parkings test",
        setUp: () {
          when(() => parkingRepository.addParking(any()))
              .thenAnswer((_) async => newParking);
          when(() => parkingRepository.getAllParkings())
              .thenAnswer((_) async => [...existingParkings, newParking]);
        },
        build: buildBloc,
        seed: () => ActiveParkingsLoaded(parkings: existingParkings),
        act: (bloc) => bloc.add(CreateParking(parking: newParking)),
        expect: () => [
          ParkingsLoading(),
          ActiveParkingsLoaded(parkings: [...existingParkings, newParking])
        ],
        verify: (_) {
          verify(() => parkingRepository.addParking(any())).called(1);
          verify(() => parkingRepository.getAllParkings()).called(1);
        },
      );

      blocTest<ParkingBloc, ParkingState>(
        'emits [ParkingError] when create fails',
        setUp: () {
          when(() => parkingRepository.addParking(any()))
              .thenThrow(Exception('Failed to create parkings'));
        },
        build: buildBloc,
        seed: () => ActiveParkingsLoaded(parkings: existingParkings),
        act: (bloc) => bloc.add(CreateParking(parking: newParking)),
        expect: () => [
          ParkingsError(message: 'Exception: Failed to create parkings'),
        ],
      );
    });

    group("Update parkings", () {
      final parkingToUpdate = Parking(
        id: '1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        parkingSpace:
            ParkingSpace(id: '1', address: 'Testadress 1', pricePerHour: 10),
        vehicle: Vehicle(
            regNr: 'REG111',
            vehicleType: 'Car',
            owner: Person(
              name: 'Namn1',
              socialSecurityNumber: '111111111111',
              email: 'test@test1.se',
            )),
      );
      final existingParkings = [
        Parking(
          id: '1',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          parkingSpace:
              ParkingSpace(id: '1', address: 'Testadress 1', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG111',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn1',
                socialSecurityNumber: '111111111111',
                email: 'test@test1.se',
              )),
        ),
        Parking(
          id: '2',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          parkingSpace:
              ParkingSpace(id: '2', address: 'Testadress 2', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG222',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn2',
                socialSecurityNumber: '222222222222',
                email: 'test@test2.se',
              )),
        )
      ];
      blocTest<ParkingBloc, ParkingState>(
        "update parkings test",
        setUp: () {
          when(() => parkingRepository.updateParkings(any()))
              .thenAnswer((_) async => parkingToUpdate);
          when(() => parkingRepository.getAllParkings())
              .thenAnswer((_) async => [parkingToUpdate, existingParkings[1]]);
        },
        build: buildBloc,
        seed: () => ActiveParkingsLoaded(parkings: existingParkings),
        act: (bloc) => bloc.add(UpdateParking(parking: parkingToUpdate)),
        expect: () => [
          ParkingsLoading(),
          ActiveParkingsLoaded(
              parkings: [parkingToUpdate, existingParkings[1]]),
        ],
        verify: (_) {
          verify(() => parkingRepository.updateParkings(any())).called(1);
          verify(() => parkingRepository.getAllParkings()).called(1);
        },
      );

      blocTest<ParkingBloc, ParkingState>(
        'emits [ParkingError] when update fails',
        setUp: () {
          when(() => parkingRepository.updateParkings(any()))
              .thenThrow(Exception('Failed to update parkings'));
        },
        build: buildBloc,
        seed: () => ActiveParkingsLoaded(parkings: existingParkings),
        act: (bloc) => bloc.add(UpdateParking(parking: parkingToUpdate)),
        expect: () => [
          ParkingsError(message: 'Exception: Failed to update parkings'),
        ],
      );
    });

    group("Delete parkings", () {
      final parkingsToDelete = Parking(
        id: '1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        parkingSpace:
            ParkingSpace(id: '1', address: 'Testadress 1', pricePerHour: 10),
        vehicle: Vehicle(
            regNr: 'REG111',
            vehicleType: 'Car',
            owner: Person(
              name: 'Namn1',
              socialSecurityNumber: '111111111111',
              email: 'test@test1.se',
            )),
      );
      final existingParkings = [
        Parking(
          id: '1',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          parkingSpace:
              ParkingSpace(id: '1', address: 'Testadress 1', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG111',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn1',
                socialSecurityNumber: '111111111111',
                email: 'test@test1.se',
              )),
        ),
        Parking(
          id: '2',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          parkingSpace:
              ParkingSpace(id: '2', address: 'Testadress 2', pricePerHour: 10),
          vehicle: Vehicle(
              regNr: 'REG222',
              vehicleType: 'Car',
              owner: Person(
                name: 'Namn2',
                socialSecurityNumber: '222222222222',
                email: 'test@test2.se',
              )),
        )
      ];

      blocTest<ParkingBloc, ParkingState>(
        "delete parkings test",
        setUp: () {
          when(() => parkingRepository.deleteParkings(any()))
              .thenAnswer((_) async => parkingsToDelete);
          when(() => parkingRepository.getAllParkings())
              .thenAnswer((_) async => [existingParkings[1]]);
        },
        build: buildBloc,
        seed: () => ActiveParkingsLoaded(parkings: existingParkings),
        act: (bloc) => bloc.add(DeleteParking(parking: parkingsToDelete)),
        expect: () => [
          ParkingsLoading(),
          ActiveParkingsLoaded(parkings: [existingParkings[1]]),
        ],
        verify: (_) {
          verify(() => parkingRepository.deleteParkings(any())).called(1);
          verify(() => parkingRepository.getAllParkings()).called(1);
        },
      );

      blocTest<ParkingBloc, ParkingState>(
        'emits [ParkingError] when delete fails',
        setUp: () {
          when(() => parkingRepository.deleteParkings(any()))
              .thenThrow(Exception('Failed to delete parkings'));
        },
        build: buildBloc,
        seed: () => ActiveParkingsLoaded(parkings: existingParkings),
        act: (bloc) => bloc.add(DeleteParking(parking: parkingsToDelete)),
        expect: () => [
          ParkingsError(message: 'Exception: Failed to delete parkings'),
        ],
      );
    });
  });
}
