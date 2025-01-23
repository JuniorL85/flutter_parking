part of 'person_bloc.dart';

sealed class PersonEvent {}

class LoadPersons extends PersonEvent {}

class LoadPersonsById extends PersonEvent {
  String id;

  LoadPersonsById({required this.id});
}

class CreatePerson extends PersonEvent {
  final Person person;

  CreatePerson({required this.person});
}

class UpdatePersons extends PersonEvent {
  final Person person;

  UpdatePersons({required this.person});
}

class DeletePersons extends PersonEvent {
  final Person person;

  DeletePersons({required this.person});
}
