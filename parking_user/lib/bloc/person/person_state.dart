part of 'person_bloc.dart';

abstract class PersonState extends Equatable {}

class PersonsInitial extends PersonState {
  @override
  List<Object?> get props => [];
}

class PersonsLoading extends PersonState {
  @override
  List<Object?> get props => [];
}

class PersonsLoaded extends PersonState {
  final List<Person> persons;

  PersonsLoaded({required this.persons});

  @override
  List<Object?> get props => [persons];
}

class PersonLoaded extends PersonState {
  final Person person;

  PersonLoaded({required this.person});

  @override
  List<Object?> get props => [person];
}

class PersonsError extends PersonState {
  final String message;

  PersonsError({required this.message});

  @override
  List<Object?> get props => [message];
}
