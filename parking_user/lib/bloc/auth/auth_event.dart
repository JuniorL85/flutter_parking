part of 'auth_bloc.dart';

sealed class AuthEvent {}

// Add this event on app start
// subscribe to auth changes
class AuthUserSubscriptionRequested extends AuthEvent {}

class Login extends AuthEvent {
  final String email;
  final String password;

  Login({required this.email, required this.password});
}

class Register extends AuthEvent {
  final String email;
  final String password;

  Register({required this.email, required this.password});
}

class Logout extends AuthEvent {}

// possible event on intermediate registration step
class FinalizeRegistration extends AuthEvent {
  final String authId;
  final String email;
  final String name;
  final String socialSecurityNumber;

  FinalizeRegistration(
      {required this.name,
      required this.authId,
      required this.email,
      required this.socialSecurityNumber});
}
