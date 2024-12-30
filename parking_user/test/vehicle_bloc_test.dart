import 'package:bloc_test/bloc_test.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/bloc/vehicle_bloc.dart';

class MockVehicleRepository extends Mock implements VehicleRepository {}

class FakeVehicle extends Fake implements Vehicle {}

void main() {
  group('VehicleBloc', () {
    late VehicleRepository vehicleRepository;

    setUp(() {
      vehicleRepository = MockVehicleRepository();
    });

    setUpAll(() {
      registerFallbackValue(FakeVehicle());
    });

    VehicleBloc buildBloc() {
      return VehicleBloc(vehicleRepository: vehicleRepository);
    }

    group("Load vehicles", () {
      final existingVehicles = [
        Vehicle(
          id: 1,
          regNr: 'REG111',
          vehicleType: 'Car',
          owner: Person(
              id: 1, name: 'Namn1', socialSecurityNumber: '111111111111'),
        ),
        Vehicle(
          id: 2,
          regNr: 'REG222',
          vehicleType: 'Car',
          owner: Person(
              id: 2, name: 'Namn2', socialSecurityNumber: '222222222222'),
        )
      ];

      blocTest<VehicleBloc, VehicleState>(
        "load vehicles test",
        setUp: () {
          when(() => vehicleRepository.getAllVehicles())
              .thenAnswer((_) async => existingVehicles);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadVehicles()),
        expect: () => [
          VehiclesLoading(),
          VehiclesLoaded(vehicles: existingVehicles),
        ],
        verify: (_) {
          verify(() => vehicleRepository.getAllVehicles()).called(1);
        },
      );

      blocTest<VehicleBloc, VehicleState>(
        'emits [VehicleError] when load fails',
        setUp: () {
          when(() => vehicleRepository.getAllVehicles())
              .thenThrow(Exception('Failed to load vehicles'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadVehicles()),
        expect: () => [
          VehiclesLoading(),
          VehiclesError(message: 'Exception: Failed to load vehicles'),
        ],
      );
    });

    group("Create vehicles", () {
      final newVehicle = Vehicle(
        regNr: 'REG333',
        vehicleType: 'Car',
        owner:
            Person(id: 3, name: 'Namn3', socialSecurityNumber: '333333333333'),
      );
      final existingVehicles = [
        Vehicle(
          id: 1,
          regNr: 'REG111',
          vehicleType: 'Car',
          owner: Person(
              id: 1, name: 'Namn1', socialSecurityNumber: '111111111111'),
        ),
        Vehicle(
          id: 2,
          regNr: 'REG222',
          vehicleType: 'Car',
          owner: Person(
              id: 2, name: 'Namn2', socialSecurityNumber: '222222222222'),
        )
      ];

      blocTest<VehicleBloc, VehicleState>(
        "create vehicles test",
        setUp: () {
          when(() => vehicleRepository.addVehicle(any()))
              .thenAnswer((_) async => newVehicle);
          when(() => vehicleRepository.getAllVehicles())
              .thenAnswer((_) async => [...existingVehicles, newVehicle]);
        },
        build: buildBloc,
        seed: () => VehiclesLoaded(vehicles: existingVehicles),
        act: (bloc) => bloc.add(CreateVehicle(vehicle: newVehicle)),
        expect: () => [
          VehiclesLoading(),
          VehiclesLoaded(vehicles: [newVehicle])
        ],
        verify: (_) {
          verify(() => vehicleRepository.addVehicle(any())).called(1);
          verify(() => vehicleRepository.getAllVehicles()).called(1);
        },
      );

      blocTest<VehicleBloc, VehicleState>(
        'emits [VehicleError] when create fails',
        setUp: () {
          when(() => vehicleRepository.addVehicle(any()))
              .thenThrow(Exception('Failed to create vehicles'));
        },
        build: buildBloc,
        seed: () => VehiclesLoaded(vehicles: existingVehicles),
        act: (bloc) => bloc.add(CreateVehicle(vehicle: newVehicle)),
        expect: () => [
          VehiclesError(message: 'Exception: Failed to create vehicles'),
        ],
      );
    });

    group("Update vehicles", () {
      final vehicleToUpdate = Vehicle(
        id: 1,
        regNr: 'REG123',
        vehicleType: 'Car',
        owner:
            Person(id: 1, name: 'Namn1', socialSecurityNumber: '111111111111'),
      );
      final existingVehicles = [
        Vehicle(
          id: 1,
          regNr: 'REG111',
          vehicleType: 'Car',
          owner: Person(
              id: 1, name: 'Namn1', socialSecurityNumber: '111111111111'),
        ),
        Vehicle(
          id: 2,
          regNr: 'REG222',
          vehicleType: 'Car',
          owner: Person(
              id: 2, name: 'Namn2', socialSecurityNumber: '222222222222'),
        )
      ];
      blocTest<VehicleBloc, VehicleState>(
        "update vehicles test",
        setUp: () {
          when(() => vehicleRepository.updateVehicles(any()))
              .thenAnswer((_) async => vehicleToUpdate);
          when(() => vehicleRepository.getAllVehicles())
              .thenAnswer((_) async => [vehicleToUpdate, existingVehicles[1]]);
        },
        build: buildBloc,
        seed: () => VehiclesLoaded(vehicles: existingVehicles),
        act: (bloc) => bloc.add(UpdateVehicles(vehicle: vehicleToUpdate)),
        expect: () => [
          VehiclesLoading(),
          VehiclesLoaded(vehicles: [vehicleToUpdate]),
        ],
        verify: (_) {
          verify(() => vehicleRepository.updateVehicles(any())).called(1);
          verify(() => vehicleRepository.getAllVehicles()).called(1);
        },
      );

      blocTest<VehicleBloc, VehicleState>(
        'emits [VehicleError] when update fails',
        setUp: () {
          when(() => vehicleRepository.updateVehicles(any()))
              .thenThrow(Exception('Failed to update vehicles'));
        },
        build: buildBloc,
        seed: () => VehiclesLoaded(vehicles: existingVehicles),
        act: (bloc) => bloc.add(UpdateVehicles(vehicle: vehicleToUpdate)),
        expect: () => [
          VehiclesError(message: 'Exception: Failed to update vehicles'),
        ],
      );
    });

    group("Delete vehicles", () {
      final vehiclesToDelete = Vehicle(
        id: 1,
        regNr: 'REG111',
        vehicleType: 'Car',
        owner:
            Person(id: 1, name: 'Namn1', socialSecurityNumber: '111111111111'),
      );
      final existingVehicles = [
        Vehicle(
          id: 1,
          regNr: 'REG111',
          vehicleType: 'Car',
          owner: Person(
              id: 1, name: 'Namn1', socialSecurityNumber: '111111111111'),
        ),
        Vehicle(
          id: 2,
          regNr: 'REG222',
          vehicleType: 'Car',
          owner: Person(
              id: 2, name: 'Namn2', socialSecurityNumber: '222222222222'),
        )
      ];

      blocTest<VehicleBloc, VehicleState>(
        "delete vehicles test",
        setUp: () {
          when(() => vehicleRepository.deleteVehicle(any()))
              .thenAnswer((_) async => vehiclesToDelete);
          when(() => vehicleRepository.getAllVehicles())
              .thenAnswer((_) async => [existingVehicles[1]]);
        },
        build: buildBloc,
        seed: () => VehiclesLoaded(vehicles: existingVehicles),
        act: (bloc) => bloc.add(DeleteVehicles(vehicle: vehiclesToDelete)),
        expect: () => [
          VehiclesLoading(),
          VehiclesLoaded(vehicles: const []),
        ],
        verify: (_) {
          verify(() => vehicleRepository.deleteVehicle(any())).called(1);
          verify(() => vehicleRepository.getAllVehicles()).called(1);
        },
      );

      blocTest<VehicleBloc, VehicleState>(
        'emits [VehicleError] when delete fails',
        setUp: () {
          when(() => vehicleRepository.deleteVehicle(any()))
              .thenThrow(Exception('Failed to delete vehicles'));
        },
        build: buildBloc,
        seed: () => VehiclesLoaded(vehicles: existingVehicles),
        act: (bloc) => bloc.add(DeleteVehicles(vehicle: vehiclesToDelete)),
        expect: () => [
          VehiclesError(message: 'Exception: Failed to delete vehicles'),
        ],
      );
    });
  });
}
