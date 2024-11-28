import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/screens/login.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final formKey = GlobalKey<FormState>();
  String? name;
  String? socialSecurityNumber;
  List<Person> personList = [];

  @override
  void initState() {
    super.initState();
    getPersonList();
  }

  getPersonList() async {
    personList = await PersonRepository.instance.getAllPersons();
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
                const SizedBox(height: 10),
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
                            final res =
                                await PersonRepository.instance.addPerson(
                              Person(
                                name: name!,
                                socialSecurityNumber: socialSecurityNumber!,
                              ),
                            );

                            if (res.statusCode == 200) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.lightGreen,
                                    content: Text('Du har skapat ett konto'),
                                  ),
                                );

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => const Login(),
                                  ),
                                );
                              }
                              formKey.currentState?.reset();
                              setState(() {
                                getPersonList();
                              });
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    duration: Duration(seconds: 3),
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        'Något gick fel vänligen försök igen senare'),
                                  ),
                                );
                              }
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                      'Finns redan en person med detta personnummer, gå tillbaka till inloggningsidan'),
                                ),
                              );
                            }
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
