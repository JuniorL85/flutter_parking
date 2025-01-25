import 'package:bloc_test/bloc_test.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/bloc/parking_space/parking_spaces_bloc.dart';

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
        ParkingSpace(
            id: '1',
            creatorId: 'Admin1',
            address: 'Testadress 1',
            pricePerHour: 10),
        ParkingSpace(
            id: '2',
            creatorId: 'Admin1',
            address: 'Testadress 2',
            pricePerHour: 20)
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
  });
}
