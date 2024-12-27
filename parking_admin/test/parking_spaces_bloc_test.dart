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

    group("create parkingSpace", () {
      ParkingSpace newParkingSpace = ParkingSpace(
          address: 'Testadress 44, 555 66 Testar', pricePerHour: 12);

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        "create parkingspace test",
        setUp: () {
          when(() => parkingSpaceRepository.addParkingSpace(any()))
              .thenAnswer((_) async => newParkingSpace);
          when(() => parkingSpaceRepository.getAllParkingSpaces())
              .thenAnswer((_) async => [newParkingSpace]);
        },
        build: () =>
            ParkingSpacesBloc(parkingSpaceRepository: parkingSpaceRepository),
        seed: () => ParkingSpacesLoaded(parkingSpaces: const []),
        act: (bloc) =>
            bloc.add(CreateParkingSpace(parkingSpace: newParkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(parkingSpaces: [newParkingSpace])
        ],
        verify: (_) {
          verify(() => parkingSpaceRepository.addParkingSpace(any())).called(1);
        },
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'emits [ParkingSpacesError] when create fails',
        setUp: () {
          when(() => parkingSpaceRepository.addParkingSpace(any()))
              .thenThrow(Exception('Failed to create parkingSpace'));
        },
        build: () =>
            ParkingSpacesBloc(parkingSpaceRepository: parkingSpaceRepository),
        seed: () => ParkingSpacesLoaded(parkingSpaces: const []),
        act: (bloc) =>
            bloc.add(CreateParkingSpace(parkingSpace: newParkingSpace)),
        expect: () => [
          ParkingSpacesError(
              message: 'Exception: Failed to create parkingSpace'),
        ],
      );
    });

    // group("delete parkingSpace", () {
    //   ParkingSpace newParkingSpace = ParkingSpace(
    //       address: 'Testadress 44, 555 66 Testar', pricePerHour: 12);

    //   blocTest<ParkingSpacesBloc, ParkingSpacesState>(
    //     "delete parkingspace test",
    //     setUp: () {
    //       when(() => parkingSpaceRepository.deleteParkingSpace(any()))
    //           .thenAnswer((_) async => newParkingSpace);
    //       when(() => parkingSpaceRepository.getAllParkingSpaces())
    //           .thenAnswer((_) async => [newParkingSpace]);
    //     },
    //     build: () =>
    //         ParkingSpacesBloc(parkingSpaceRepository: parkingSpaceRepository),
    //     seed: () => ParkingSpacesLoaded(parkingSpaces: const []),
    //     act: (bloc) =>
    //         bloc.add(CreateParkingSpace(parkingSpace: newParkingSpace)),
    //     expect: () => [
    //       ParkingSpacesLoaded(parkingSpaces: [newParkingSpace])
    //     ],
    //     verify: (_) {
    //       verify(() => parkingSpaceRepository.addParkingSpace(any())).called(1);
    //     },
    //   );
    // });
  });
}
