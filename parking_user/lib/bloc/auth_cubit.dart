import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
}

class AuthCubit extends HydratedCubit<AuthStatus> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  final PersonRepository personRepository;
  List<Person> _personList = [];
  AuthCubit({required this.personRepository})
      : super(AuthStatus.unauthenticated);

  Future<void> login(String socialSecurityNumber) async {
    try {
      // Simulate API call
      emit(AuthStatus.authenticating);
      await Future.delayed(const Duration(seconds: 2));
      _personList = await personRepository.getAllPersons();
      final index = _personList
          .indexWhere((i) => i.socialSecurityNumber == socialSecurityNumber);
      if (index != -1) {
        emit(AuthStatus.authenticated);
      } else {
        emit(AuthStatus.unauthenticated);
      }
    } catch (e) {
      emit(AuthStatus.unauthenticated);
      // You could add error handling here
    }
  }

  void logout() {
    emit(AuthStatus.unauthenticated);
  }

  @override
  AuthStatus? fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    return status == 'authenticated'
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  @override
  Map<String, dynamic>? toJson(AuthStatus state) {
    return {
      'status': switch (state) {
        AuthStatus.unauthenticated ||
        AuthStatus.authenticating =>
          "unauthenticated",
        AuthStatus.authenticated => "authenticated",
      }
    };
  }
}
