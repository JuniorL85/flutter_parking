import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/screens/create_account.dart';
import 'package:parking_user/screens/manage_account.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  String? socialSecurityNumber;

  @override
  Widget build(BuildContext context) {
    context.watch<GetPerson>().getAllPersons();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkHere'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                const Text('Logga in', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Ange ett personnummer";
                      }

                      if (!validateSocialSecurityNumber(value)) {
                        return 'Du har angivit ett felaktigt format på personnumret!';
                      }
                      return null;
                    },
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ange personnummer',
                    ),
                    onChanged: (value) => socialSecurityNumber = value,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final personList = context.read<GetPerson>().personList;
                      final index = personList.indexWhere((i) =>
                          i.socialSecurityNumber == socialSecurityNumber!);

                      if (index != -1) {
                        context
                            .read<GetPerson>()
                            .getPerson(personList[index].id);

                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const ManageAccount(),
                            ),
                          );
                          formKey.currentState?.reset();
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                  'Finns ingen person med angivet personnummer, välj skapa konto'),
                            ),
                          );
                        }
                        formKey.currentState?.reset();
                      }
                    }
                  },
                  child: const Text('Logga in'),
                ),
                const SizedBox(height: 30),
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
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
