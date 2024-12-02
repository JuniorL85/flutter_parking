import 'package:flutter/material.dart';

class ManageSettings extends StatelessWidget {
  const ManageSettings({super.key});

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
