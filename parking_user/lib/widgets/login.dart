import 'package:flutter/material.dart';

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
        child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            const Text('Logga in', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              controller: _inputController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ange personnummer',
              ),
            ),
            const SizedBox(height: 30),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _inputController,
              builder: (context, value, child) {
                return ElevatedButton(
                  onPressed: value.text.isNotEmpty ? () {} : null,
                  child: const Text('Logga in'),
                );
              },
            )
          ]),
        ),
      ),
    );
  }
}
