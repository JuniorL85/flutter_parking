import 'package:bloc_test/bloc_test.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

class FakePerson extends Fake implements Person {}

void main() {
  group('PersonBloc', () {
    late PersonRepository personRepository;

    setUp(() {
      personRepository = MockPersonRepository();
    });

    setUpAll(() {
      registerFallbackValue(FakePerson());
    });

    PersonBloc buildBloc() {
      return PersonBloc(personRepository: personRepository);
    }

    group("Load persons", () {
      final existingPerson = [
        Person(
          id: '1',
          name: 'Namn1',
          socialSecurityNumber: '111111111111',
          email: 'test@test1.se',
        ),
        Person(
          id: '2',
          name: 'Namn2',
          socialSecurityNumber: '222222222222',
          email: 'test@test2.se',
        )
      ];

      blocTest<PersonBloc, PersonState>(
        "load persons test",
        setUp: () {
          when(() => personRepository.getAllPersons())
              .thenAnswer((_) async => existingPerson);
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadPersons()),
        expect: () => [
          PersonsLoading(),
          PersonsLoaded(persons: existingPerson),
        ],
        verify: (_) {
          verify(() => personRepository.getAllPersons()).called(1);
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonError] when load fails',
        setUp: () {
          when(() => personRepository.getAllPersons())
              .thenThrow(Exception('Failed to load persons'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(LoadPersons()),
        expect: () => [
          PersonsLoading(),
          PersonsError(message: 'Exception: Failed to load persons'),
        ],
      );
    });

    group("Create persons", () {
      final newPerson = Person(
        name: 'Namn3',
        socialSecurityNumber: '333333333333',
        email: 'test@test3.se',
      );
      final existingPerson = [
        Person(
          id: '1',
          name: 'Namn1',
          socialSecurityNumber: '111111111111',
          email: 'test@test1.se',
        ),
        Person(
          id: '2',
          name: 'Namn2',
          socialSecurityNumber: '222222222222',
          email: 'test@test2.se',
        )
      ];

      blocTest<PersonBloc, PersonState>(
        "create persons test",
        setUp: () {
          when(() => personRepository.addPerson(any()))
              .thenAnswer((_) async => newPerson);
          when(() => personRepository.getAllPersons())
              .thenAnswer((_) async => [...existingPerson, newPerson]);
        },
        build: buildBloc,
        seed: () => PersonsLoaded(persons: existingPerson),
        act: (bloc) => bloc.add(CreatePerson(person: newPerson)),
        expect: () => [
          PersonsLoaded(persons: [...existingPerson, newPerson])
        ],
        verify: (_) {
          verify(() => personRepository.addPerson(any())).called(1);
          verify(() => personRepository.getAllPersons()).called(1);
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonError] when create fails',
        setUp: () {
          when(() => personRepository.addPerson(any()))
              .thenThrow(Exception('Failed to create persons'));
        },
        build: buildBloc,
        seed: () => PersonsLoaded(persons: existingPerson),
        act: (bloc) => bloc.add(CreatePerson(person: newPerson)),
        expect: () => [
          PersonsError(message: 'Exception: Failed to create persons'),
        ],
      );
    });

    group("Update persons", () {
      final personToUpdate = Person(
        id: '1',
        name: 'Namn11',
        socialSecurityNumber: '111111111111',
        email: 'test@test1.se',
      );
      final existingPerson = [
        Person(
          id: '1',
          name: 'Namn1',
          socialSecurityNumber: '111111111111',
          email: 'test@test1.se',
        ),
        Person(
          id: '2',
          name: 'Namn2',
          socialSecurityNumber: '222222222222',
          email: 'test@test2.se',
        )
      ];

      blocTest<PersonBloc, PersonState>(
        "update persons test",
        setUp: () {
          when(() => personRepository.updatePersons(any()))
              .thenAnswer((_) async => personToUpdate);
          when(() => personRepository.getPersonById(personToUpdate.id))
              .thenAnswer((_) async => personToUpdate);
        },
        build: buildBloc,
        seed: () => PersonLoaded(person: personToUpdate),
        act: (bloc) => bloc.add(UpdatePersons(person: personToUpdate)),
        expect: () => [
          PersonsLoading(),
          PersonLoaded(person: personToUpdate),
        ],
        verify: (_) {
          verify(() => personRepository.updatePersons(any())).called(1);
          verify(() => personRepository.getPersonById(any())).called(1);
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonError] when update fails',
        setUp: () {
          when(() => personRepository.updatePersons(any()))
              .thenThrow(Exception('Failed to update persons'));
        },
        build: buildBloc,
        seed: () => PersonsLoaded(persons: existingPerson),
        act: (bloc) => bloc.add(UpdatePersons(person: personToUpdate)),
        expect: () => [
          PersonsError(message: 'Exception: Failed to update persons'),
        ],
      );
    });

    group("Delete persons", () {
      final personsToDelete = Person(
        id: '1',
        name: 'Namn1',
        socialSecurityNumber: '111111111111',
        email: 'test@test1.se',
      );
      final existingPerson = [
        Person(
          id: '1',
          name: 'Namn1',
          socialSecurityNumber: '111111111111',
          email: 'test@test1.se',
        ),
        Person(
          id: '2',
          name: 'Namn2',
          socialSecurityNumber: '222222222222',
          email: 'test@test2.se',
        )
      ];

      blocTest<PersonBloc, PersonState>(
        "delete persons test",
        setUp: () {
          when(() => personRepository.deletePerson(any()))
              .thenAnswer((_) async => personsToDelete);
          when(() => personRepository.getAllPersons())
              .thenAnswer((_) async => [existingPerson[1]]);
        },
        build: buildBloc,
        seed: () => PersonsLoaded(persons: existingPerson),
        act: (bloc) => bloc.add(DeletePersons(person: personsToDelete)),
        expect: () => [
          PersonsLoaded(persons: [existingPerson[1]])
        ],
        verify: (_) {
          verify(() => personRepository.deletePerson(any())).called(1);
          verify(() => personRepository.getAllPersons()).called(1);
        },
      );

      blocTest<PersonBloc, PersonState>(
        'emits [PersonError] when delete fails',
        setUp: () {
          when(() => personRepository.deletePerson(any()))
              .thenThrow(Exception('Failed to delete persons'));
        },
        build: buildBloc,
        seed: () => PersonsLoaded(persons: existingPerson),
        act: (bloc) => bloc.add(DeletePersons(person: personsToDelete)),
        expect: () => [
          PersonsError(message: 'Exception: Failed to delete persons'),
        ],
      );
    });
  });
}
