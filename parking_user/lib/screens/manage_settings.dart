import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:provider/provider.dart';

class ManageSettings extends StatefulWidget {
  const ManageSettings({super.key});

  @override
  State<ManageSettings> createState() => _ManageSettingsState();
}

class _ManageSettingsState extends State<ManageSettings> {
  final formKey = GlobalKey<FormState>();
  String? name;

  @override
  Widget build(BuildContext context) {
    final person = context.read<GetPerson>().person;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Text(
              'Inställningar',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Form(
                    key: formKey,
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        'Uppdatera namn',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      tileColor: Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      onTap: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Uppdatera'),
                          content: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              initialValue: person.name,
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
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Avbryt'),
                              child: const Text('Avbryt'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  final res = await PersonRepository.instance
                                      .updatePersons(Person(
                                          id: person.id,
                                          name: name!,
                                          socialSecurityNumber:
                                              person.socialSecurityNumber));
                                  if (res.statusCode == 200) {
                                    if (context.mounted) {
                                      context
                                          .read<GetPerson>()
                                          .getPerson(person.id);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.lightGreen,
                                          content: Text(
                                              'Du har uppdaterat ditt konto'),
                                        ),
                                      );
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                              'Något gick fel vänligen försök igen senare'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  }
                                }
                              },
                              child: const Text('Uppdatera'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text(
                      'Radera konto',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    tileColor: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    onTap: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Radera konto'),
                        content: const Text(
                            'Är du säker på att du vill radera ditt konto? Det går inte att ångra efter att du tryckt på knappen "Radera konto".'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Avbryt'),
                            child: const Text('Avbryt'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final res = await PersonRepository.instance
                                  .deletePerson(person);
                              if (res.statusCode == 200) {
                                if (context.mounted) {
                                  Provider.of<GetPerson>(context, listen: false)
                                      .getAllPersons();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.lightGreen,
                                      content:
                                          Text('Du har raderat ditt konto!'),
                                    ),
                                  );
                                  setState(() {
                                    Navigator.popUntil(
                                        context, ModalRoute.withName('/'));
                                  });
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.redAccent,
                                      content: Text(
                                          'Något gick fel vänligen försök igen senare'),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              }
                            },
                            child: const Text('Radera konto'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(
                      'Logga ut',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    tileColor: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    onTap: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
