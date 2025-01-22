import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final formKey = GlobalKey<FormState>();
  String? name;
  String? socialSecurityNumber;
  String? email;
  String? password;
  List<Person> personList = [];
  StreamSubscription? personSubscription;
  StreamSubscription? _blocSubscription;

  @override
  void initState() {
    super.initState();
    getPersonList();
  }

  @override
  void dispose() {
    personSubscription?.cancel();
    _blocSubscription?.cancel();
    super.dispose();
  }

  getPersonList() async {
    if (mounted) {
      context.read<PersonBloc>().add(LoadPersons());
      personSubscription = context.read<PersonBloc>().stream.listen((state) {
        if (state is PersonsLoaded) {
          setState(() {
            personList = state.persons;
          });
        }
      });
    }
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
                      return "Ange ett namn";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ange namn',
                  ),
                  onChanged: (value) => name = value,
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
                ),
                const SizedBox(height: 5),
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
                ),
                // const SizedBox(height: 5),
                // TextFormField(
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return "Ange ett lösenord";
                //     }
                //     return null;
                //   },
                //   decoration: const InputDecoration(
                //     border: OutlineInputBorder(),
                //     labelText: 'Ange ditt lösenord',
                //   ),
                //   onChanged: (value) => password = value,
                // ),
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
                          final index = personList.indexWhere((i) =>
                              i.socialSecurityNumber == socialSecurityNumber!);

                          if (index == -1) {
                            if (context.mounted) {
                              final bloc = context.read<PersonBloc>();

                              _blocSubscription = bloc.stream.listen((state) {
                                if (state is PersonsLoaded) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.lightGreen,
                                      content: Text('Du har skapat ett konto'),
                                    ),
                                  );

                                  formKey.currentState?.reset();
                                  Navigator.of(context).pop();
                                } else if (state is PersonsError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.redAccent,
                                      content: Text(state.message),
                                    ),
                                  );
                                }
                              });
                              context.read<PersonBloc>().add(CreatePerson(
                                      person: Person(
                                    name: name!,
                                    socialSecurityNumber: socialSecurityNumber!,
                                    email: email!,
                                  )));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                    'Finns redan en person med detta personnummer, gå tillbaka till inloggningsidan'),
                              ),
                            );
                            formKey.currentState?.reset();
                          }
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
