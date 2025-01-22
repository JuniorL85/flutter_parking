part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {}

// app start state, unknown
class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

// attempting to login
class AuthPending extends AuthState {
  @override
  List<Object?> get props => [];
}

// something went wrong
class AuthFail extends AuthState {
  final String message;

  AuthFail({required this.message});

  @override
  List<Object?> get props => [message];
}

// user is logged in and user exists in database
class Authenticated extends AuthState {
  final Person person;

  Authenticated({required this.person});

  @override
  List<Object?> get props => [person];
}

// forgoing naming convention for the sake of clarity

// user exists in auth but not in DB
class AuthenticatedNoUser extends AuthState {
  final String authId;
  final String email;

  AuthenticatedNoUser({required this.authId, required this.email});

  @override
  List<Object?> get props => [authId, email];
}

// finalizing user registration (creating user in database)
class AuthenticatedNoUserPending extends AuthState {
  final String authId;
  final String email;

  AuthenticatedNoUserPending({required this.authId, required this.email});

  @override
  List<Object?> get props => [authId, email];
}

// forgoing naming convention for the sake of clarity
class Unauthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}
