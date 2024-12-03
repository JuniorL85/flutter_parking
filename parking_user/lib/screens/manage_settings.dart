import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class ManageSettings extends StatefulWidget {
  const ManageSettings({super.key, required this.person});

  final Person? person;

  @override
  State<ManageSettings> createState() => _ManageSettingsState();
}

class _ManageSettingsState extends State<ManageSettings> {
  @override
  Widget build(BuildContext context) {
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
                  ListTile(
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
                                  .deletePerson(widget.person!);
                              if (res.statusCode == 200) {
                                if (context.mounted) {
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
