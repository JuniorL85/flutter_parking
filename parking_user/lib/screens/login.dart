import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth/auth_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/screens/create_account.dart';
import 'package:parking_user/screens/finalize_account.dart';
import 'package:parking_user/screens/manage_account.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  StreamSubscription? _blocSubscription;

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ParkHere'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Theme.of(context).colorScheme.inversePrimary,
                  Theme.of(context).colorScheme.onInverseSurface
                ]),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Image.asset(
              'assets/images/ph.png',
              height: 40,
              width: 40,
              opacity: const AlwaysStoppedAnimation(0.5),
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: <Color>[
                        Theme.of(context).colorScheme.onInverseSurface,
                        Theme.of(context).colorScheme.inversePrimary
                      ]),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 20),
                      Text(
                        'Logga in',
                        style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Ange en e-post adress";
                                }
                                return null;
                              },
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Ange din e-postadress',
                              ),
                              onChanged: (value) => email = value,
                              onSaved: (value) => email = value,
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
                              obscureText: true,
                              autocorrect: false,
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Ange ett lösenord";
                                }
                                return null;
                              },
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                labelText: 'Ange ditt lösenord',
                              ),
                              onChanged: (value) => password = value,
                              onSaved: (value) => password = value,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();

                            final bloc = context.read<AuthBloc>();

                            _blocSubscription = bloc.stream.listen((state) {
                              if (state is Authenticated) {
                                if (context.mounted) {
                                  context.read<PersonBloc>().add(
                                      LoadPersonsById(id: state.person.id));
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => const ManageAccount(),
                                      ),
                                    );
                                    formKey.currentState?.reset();
                                  }
                                }
                              } else if (state is AuthenticatedNoUser) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => FinalizeAccount(
                                        authId: state.authId,
                                        email: state.email,
                                      ),
                                    ),
                                  );
                                  formKey.currentState?.reset();
                                }
                              } else if (state is AuthPending ||
                                  state is AuthenticatedNoUserPending) {
                                if (context.mounted) {
                                  showDialog(
                                    barrierDismissible: false,
                                    builder: (ctx) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                    context: context,
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.redAccent,
                                      content: Text(
                                          'Finns ingen person med angivna inloggingsuppgifter, välj skapa konto'),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                                formKey.currentState?.reset();
                              }
                            });
                            context
                                .read<AuthBloc>()
                                .add(Login(email: email!, password: password!));
                          }
                        },
                        child: const Text('Logga in'),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Inget konto?'),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => const CreateAccount(),
                                ),
                              );
                              formKey.currentState?.reset();
                            },
                            child: const Text('Skapa konto'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
