import 'dart:async';

import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth/auth_bloc.dart';

class FinalizeAccount extends StatefulWidget {
  const FinalizeAccount({super.key, required this.email, required this.authId});

  final String email;
  final String authId;

  @override
  State<FinalizeAccount> createState() => _FinalizeAccountState();
}

class _FinalizeAccountState extends State<FinalizeAccount> {
  final formKey = GlobalKey<FormState>();
  String? name;
  String? socialSecurityNumber;
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
        title: const Text('Slutför kontoregistrering'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ange ett namn";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ange namn',
                  ),
                  onChanged: (value) => name = value,
                  onSaved: (value) => name = value,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !validateSocialSecurityNumber(value)) {
                      return "Ange ett korrekt personnummer (12 siffror)";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ange personnummer',
                  ),
                  onChanged: (value) => socialSecurityNumber = value,
                  onSaved: (value) => socialSecurityNumber = value,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Avbryt'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();

                          final bloc = context.read<AuthBloc>();

                          _blocSubscription = bloc.stream.listen((state) {
                            if (state is Authenticated) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.lightGreen,
                                    content: Text('Du har skapat ett konto'),
                                  ),
                                );

                                formKey.currentState?.reset();
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/'));
                              }
                            } else if (state is AuthenticatedNoUserPending) {
                              const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is AuthFail) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                      'Något gick fel, vänligen försök igen senare'),
                                ),
                              );
                            }
                          });
                          context.read<AuthBloc>().add(FinalizeRegistration(
                                email: widget.email,
                                authId: widget.authId,
                                name: name!,
                                socialSecurityNumber: socialSecurityNumber!,
                              ));
                        }
                      },
                      child: const Text('Slutför registrering'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
