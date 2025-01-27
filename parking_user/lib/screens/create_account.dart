import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth/auth_bloc.dart';
import 'package:parking_user/screens/finalize_account.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  // var authState;
  StreamSubscription? _blocSubscription;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // authState = context.watch<AuthBloc>().state;
  // }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skapa konto'),
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
                      return "Ange en e-postadress";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ange din e-postadress',
                  ),
                  onChanged: (value) => email = value,
                  onSaved: (value) => email = value,
                ),
                const SizedBox(height: 5),
                TextFormField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ange ett lösenord";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ange ditt lösenord',
                  ),
                  onChanged: (value) => password = value,
                  onSaved: (value) => password = value,
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
                            if (state is AuthenticatedNoUser) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
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
                            } else if (state is AuthFail) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Colors.redAccent,
                                    content: Text(state.message),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        'Något gick fel, vänligen försök igen senare'),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          });
                          context.read<AuthBloc>().add(
                              Register(email: email!, password: password!));
                        }
                      },
                      child: const Text('Skapa konto'),
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
