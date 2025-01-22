import 'package:bloc/bloc.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_repositories/firebase_repositories.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final PersonRepository personRepository;

  AuthBloc({required this.authRepository, required this.personRepository})
      : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      try {
        switch (event) {
          case Login(:final email, :final password):
            await _onLogin(emit, email, password);
          case Register(:final email, :final password):
            await _onRegister(emit, email, password);

          case Logout():
            await onLogout(emit);
          case AuthUserSubscriptionRequested():
            // todo: perhaps return
            emit.onEach(authRepository.userStream, onData: (authUser) async {
              if (authUser == null) {
                emit(Unauthenticated());
              } else {
                // user is authenticated in firebase auth, does user exist in db?
                Person? person =
                    await personRepository.getPersonById(authUser.uid);
                if (person == null) {
                  emit(AuthenticatedNoUser(
                      authId: authUser.uid, email: authUser.email!));
                } else {
                  emit(Authenticated(person: person));
                }
              }
            });

          case FinalizeRegistration(
              :final authId,
              :final name,
              :final email,
              :final socialSecurityNumber,
            ):
            await _handleFinalizeRegistration(
                authId, email, name, socialSecurityNumber, emit);
        }
      } on Exception catch (e) {
        emit(AuthFail(message: e.toString()));
      }
    });
  }

  Future<void> _handleFinalizeRegistration(String authId, String email,
      String name, String socialSecurityNumber, Emitter<AuthState> emit) async {
    emit(AuthenticatedNoUserPending(authId: authId, email: email));
    final person = await personRepository.addPerson(Person(
        email: email,
        id: authId,
        name: name,
        socialSecurityNumber: socialSecurityNumber));
    // this operation does not trigger a change on the auth stream.
    emit(Authenticated(person: person));
  }

  Future<void> _onLogin(
      Emitter<AuthState> emit, String email, String password) async {
    emit(AuthPending());
    await authRepository.login(email: email, password: password);
  }

  Future<void> onLogout(Emitter<AuthState> emit) async {
    await authRepository.logout();
    // no reason to emit state here because this triggers a change on the authStateChanges stream
    // the stream handler will emit the appropriate state
  }

  Future<void> _onRegister(
      Emitter<AuthState> emit, String email, String password) async {
    emit(AuthPending());
    await authRepository.register(email: email, password: password);
  }
}
