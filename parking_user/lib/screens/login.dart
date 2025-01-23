import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth/auth_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/screens/create_account.dart';
import 'package:parking_user/screens/manage_account.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final formKey = GlobalKey<FormState>();
  final _key = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController socialSecurityNumberController =
      TextEditingController();
  String? email;
  String? password;
  List<Person> personList = [];
  StreamSubscription? personSubscription;

  @override
  void initState() {
    super.initState();
    getPersonList();
  }

  @override
  void dispose() {
    personSubscription?.cancel();
    super.dispose();
  }

  getPersonList() async {
    print('jag körs visst!');

    if (mounted) {
      context.read<PersonBloc>().add(LoadPersons());
      personSubscription = context.read<PersonBloc>().stream.listen((state) {
        if (state is PersonsLoaded) {
          print('personer är laddade');
          setState(() {
            personList = state.persons;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkHere'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Theme.of(context).colorScheme.onInverseSurface,
                  Theme.of(context).colorScheme.inversePrimary
                ]),
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
                            ),
                            const SizedBox(height: 5),
                            TextFormField(
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
                            ),
                            // TextFormField(
                            //   validator: (value) {
                            //     if (value == null || value.isEmpty) {
                            //       return "Ange ett personnummer";
                            //     }

                            //     if (!validateSocialSecurityNumber(value)) {
                            //       return 'Du har angivit ett felaktigt format på personnumret!';
                            //     }
                            //     return null;
                            //   },
                            //   textAlign: TextAlign.center,
                            //   decoration: InputDecoration(
                            //     border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(10)),
                            //     labelText: 'Ange personnummer',
                            //   ),
                            //   onChanged: (value) =>
                            //       socialSecurityNumber = value,
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            context
                                .read<AuthBloc>()
                                .add(Login(email: email!, password: password!));

                            await Future.delayed(const Duration(seconds: 1));

                            if (authState is Authenticated) {
                              context.read<PersonBloc>().add(
                                  LoadPersonsById(id: authState.person.id));
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => const ManageAccount(),
                                  ),
                                );
                                formKey.currentState?.reset();
                              }
                            } else if (authState is AuthenticatedNoUser) {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text(
                                      'Nu är det bara några uppgifter kvar'),
                                  content: Form(
                                    key: _key,
                                    child: Column(
                                      children: [
                                        const Text(
                                            'Fyll i namn och personnummer för att slutföra registreringen'),
                                        TextFormField(
                                          controller: nameController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Ange ett namn";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Ange namn',
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller:
                                              socialSecurityNumberController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                !validateSocialSecurityNumber(
                                                    value)) {
                                              return "Ange ett korrekt personnummer (12 siffror)";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Ange personnummer',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Avbryt'),
                                      child: const Text('Avbryt'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (_key.currentState!.validate()) {
                                          context
                                              .read<AuthBloc>()
                                              .add(FinalizeRegistration(
                                                email: authState.email,
                                                authId: authState.authId,
                                                name: nameController.text,
                                                socialSecurityNumber:
                                                    socialSecurityNumberController
                                                        .text,
                                              ));

                                          if (authState is Authenticated) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                duration: Duration(seconds: 3),
                                                backgroundColor:
                                                    Colors.lightGreen,
                                                content: Text(
                                                    'Du har skapat ett konto, testa att logga in på nytt'),
                                              ),
                                            );

                                            formKey.currentState?.reset();
                                            _key.currentState?.reset();
                                            Navigator.pop(context);
                                          }
                                        }
                                      },
                                      child: const Text('Skapa konto'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        'Finns ingen person med angivna inloggingsuppgifter, välj skapa konto'),
                                  ),
                                );
                              }
                              formKey.currentState?.reset();
                            }
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
