import 'package:bloc_test/bloc_test.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_admin/bloc/parking_spaces_bloc.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}

class FakeParkingSpace extends Fake implements ParkingSpace {}

void main() {
  group('ParkingSpacesBloc', () {
    late ParkingSpaceRepository parkingSpaceRepository;

    setUp(() {
      parkingSpaceRepository = MockParkingSpaceRepository();
    });

    setUpAll(() {
      registerFallbackValue(FakeParkingSpace());
    });

    ParkingSpacesBloc buildBloc() {
      return ParkingSpacesBloc(parkingSpaceRepository: parkingSpaceRepository);
    }

    group("Load parkingSpaces", () {
      final existingParkingSpaces = [
        ParkingSpace(id: 1, address: 'Testadress 1', pricePerHour: 10),
        ParkingSpace(id: 2, address: 'Testadress 2', pricePerHour: 20)
      ];

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        "load parkingspaces test",
        setUp: () {
          when(() => parkingSpaceRepository.getAllParkingSpaces())
              .thenAnswer((_) async => existingParkingSpaces);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadParkingSpaces()),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesLoaded(parkingSpaces: existingParkingSpaces),
        ],
        verify: (_) {
          verify(() => parkingSpaceRepository.getAllParkingSpaces()).called(1);
        },
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'emits [ParkingSpacesError] when load fails',
        setUp: () {
          when(() => parkingSpaceRepository.getAllParkingSpaces())
              .thenThrow(Exception('Failed to load parkingSpaces'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadParkingSpaces()),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesError(
              message: 'Exception: Failed to load parkingSpaces'),
        ],
      );
    });

    group("Create parkingSpace", () {
      final newParkingSpace = ParkingSpace(
          address: 'Testadress 44, 555 66 Testar', pricePerHour: 12);
      final existingParkingSpaces = [
        ParkingSpace(id: 1, address: 'Testadress 1', pricePerHour: 10),
        ParkingSpace(id: 2, address: 'Testadress 2', pricePerHour: 20)
      ];

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        "create parkingspace test",
        setUp: () {
          when(() => parkingSpaceRepository.addParkingSpace(any()))
              .thenAnswer((_) async => newParkingSpace);
          when(() => parkingSpaceRepository.getAllParkingSpaces()).thenAnswer(
              (_) async => [...existingParkingSpaces, newParkingSpace]);
        },
        build: buildBloc,
        seed: () => ParkingSpacesLoaded(parkingSpaces: existingParkingSpaces),
        act: (bloc) =>
            bloc.add(CreateParkingSpace(parkingSpace: newParkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [...existingParkingSpaces, newParkingSpace])
        ],
        verify: (_) {
          verify(() => parkingSpaceRepository.addParkingSpace(any())).called(1);
          verify(() => parkingSpaceRepository.getAllParkingSpaces()).called(1);
        },
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'emits [ParkingSpacesError] when create fails',
        setUp: () {
          when(() => parkingSpaceRepository.addParkingSpace(any()))
              .thenThrow(Exception('Failed to create parkingSpace'));
        },
        build: buildBloc,
        seed: () => ParkingSpacesLoaded(parkingSpaces: existingParkingSpaces),
        act: (bloc) =>
            bloc.add(CreateParkingSpace(parkingSpace: newParkingSpace)),
        expect: () => [
          ParkingSpacesError(
              message: 'Exception: Failed to create parkingSpace'),
        ],
      );
    });

    group("Update parkingSpace", () {
      final parkingSpaceToUpdate =
          ParkingSpace(id: 1, address: 'Testadress 11', pricePerHour: 10);
      final existingParkingSpaces = [
        ParkingSpace(id: 1, address: 'Testadress 1', pricePerHour: 10),
        ParkingSpace(id: 2, address: 'Testadress 2', pricePerHour: 20)
      ];

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        "update parkingspace test",
        setUp: () {
          when(() => parkingSpaceRepository.updateParkingSpace(any()))
              .thenAnswer((_) async => parkingSpaceToUpdate);
          when(() => parkingSpaceRepository.getAllParkingSpaces()).thenAnswer(
              (_) async => [parkingSpaceToUpdate, existingParkingSpaces[1]]);
        },
        build: buildBloc,
        seed: () => ParkingSpacesLoaded(parkingSpaces: existingParkingSpaces),
        act: (bloc) =>
            bloc.add(UpdateParkingSpace(parkingSpace: parkingSpaceToUpdate)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [parkingSpaceToUpdate, existingParkingSpaces[1]])
        ],
        verify: (_) {
          verify(() => parkingSpaceRepository.updateParkingSpace(any()))
              .called(1);
          verify(() => parkingSpaceRepository.getAllParkingSpaces()).called(1);
        },
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'emits [ParkingSpacesError] when update fails',
        setUp: () {
          when(() => parkingSpaceRepository.updateParkingSpace(any()))
              .thenThrow(Exception('Failed to update parkingSpace'));
        },
        build: buildBloc,
        seed: () => ParkingSpacesLoaded(parkingSpaces: existingParkingSpaces),
        act: (bloc) =>
            bloc.add(UpdateParkingSpace(parkingSpace: parkingSpaceToUpdate)),
        expect: () => [
          ParkingSpacesError(
              message: 'Exception: Failed to update parkingSpace'),
        ],
      );
    });

    group("Delete parkingSpace", () {
      final parkingSpaceToDelete =
          ParkingSpace(id: 1, address: 'Testadress 1', pricePerHour: 10);
      final existingParkingSpaces = [
        ParkingSpace(id: 1, address: 'Testadress 1', pricePerHour: 10),
        ParkingSpace(id: 2, address: 'Testadress 2', pricePerHour: 20)
      ];

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        "delete parkingspace test",
        setUp: () {
          when(() => parkingSpaceRepository.deleteParkingSpace(any()))
              .thenAnswer((_) async => parkingSpaceToDelete);
          when(() => parkingSpaceRepository.getAllParkingSpaces())
              .thenAnswer((_) async => [existingParkingSpaces[1]]);
        },
        build: buildBloc,
        seed: () => ParkingSpacesLoaded(parkingSpaces: existingParkingSpaces),
        act: (bloc) =>
            bloc.add(DeleteParkingSpace(parkingSpace: parkingSpaceToDelete)),
        expect: () => [
          ParkingSpacesLoaded(parkingSpaces: [existingParkingSpaces[1]])
        ],
        verify: (_) {
          verify(() => parkingSpaceRepository.deleteParkingSpace(any()))
              .called(1);
          verify(() => parkingSpaceRepository.getAllParkingSpaces()).called(1);
        },
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'emits [ParkingSpacesError] when delete fails',
        setUp: () {
          when(() => parkingSpaceRepository.deleteParkingSpace(any()))
              .thenThrow(Exception('Failed to delete parkingSpace'));
        },
        build: buildBloc,
        seed: () => ParkingSpacesLoaded(parkingSpaces: existingParkingSpaces),
        act: (bloc) =>
            bloc.add(DeleteParkingSpace(parkingSpace: parkingSpaceToDelete)),
        expect: () => [
          ParkingSpacesError(
              message: 'Exception: Failed to delete parkingSpace'),
        ],
      );
    });
  });
}
