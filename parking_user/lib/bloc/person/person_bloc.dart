import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';

part 'person_event.dart';
part 'person_state.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  final PersonRepository personRepository;
  List<Person> _personList = [];
  PersonBloc({required this.personRepository}) : super(PersonsInitial()) {
    on<LoadPersons>((event, emit) async {
      await onLoadPersons(emit);
    });

    on<LoadPersonsById>((event, emit) async {
      await onLoadPersonsById(emit, event.id);
    });

    on<DeletePersons>((event, emit) async {
      await onDeletePerson(emit, event.person);
    });

    on<CreatePerson>((event, emit) async {
      await onCreatePerson(emit, event.person);
    });

    on<UpdatePersons>((event, emit) async {
      await onUpdatePerson(emit, event.person);
    });
  }

  Future<void> onLoadPersons(Emitter<PersonState> emit) async {
    emit(PersonsLoading());
    try {
      _personList = await personRepository.getAllPersons();
      emit(PersonsLoaded(persons: _personList));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  Future<void> onLoadPersonsById(Emitter<PersonState> emit, String id) async {
    emit(PersonsLoading());
    try {
      final personById = await personRepository.getPersonById(id);
      emit(PersonLoaded(person: personById));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onCreatePerson(Emitter<PersonState> emit, Person person) async {
    try {
      await personRepository.addPerson(Person(
        name: person.name,
        socialSecurityNumber: person.socialSecurityNumber,
        email: person.email,
      ));

      _personList = await personRepository.getAllPersons();
      emit(PersonsLoaded(persons: _personList));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onUpdatePerson(Emitter<PersonState> emit, Person person) async {
    try {
      await personRepository.updatePersons(Person(
        id: person.id,
        name: person.name,
        socialSecurityNumber: person.socialSecurityNumber,
        email: person.email,
      ));

      add(LoadPersonsById(id: person.id));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  onDeletePerson(Emitter<PersonState> emit, Person person) async {
    try {
      await personRepository.deletePerson(Person(
        id: person.id,
        name: person.name,
        socialSecurityNumber: person.socialSecurityNumber,
        email: person.email,
      ));

      _personList = await personRepository.getAllPersons();
      emit(PersonsLoaded(persons: _personList));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }
}
