import 'package:flutter/material.dart';
import 'package:parking_user/screens/create_account.dart';
import 'package:parking_user/screens/manage_account.dart';

class Login extends StatelessWidget {
  Login({super.key});
  final TextEditingController _inputController = TextEditingController();

  void dispose() {
    _inputController.dispose();
    // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkHere'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Card(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const Text('Logga in', style: TextStyle(fontSize: 30)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: _inputController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Ange personnummer',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _inputController,
                builder: (context, value, child) {
                  return ElevatedButton(
                    onPressed: value.text.isNotEmpty
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const ManageAccount(),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Logga in'),
                  );
                },
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const CreateAccount(),
                    ),
                  );
                },
                child: const Text('Skapa konto'),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
