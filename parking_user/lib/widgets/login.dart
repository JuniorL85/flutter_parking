import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ParkHere'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            SizedBox(
              width: 250,
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Personnummer',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: null,
              child: Text('Disabled'),
            ),
          ]),
        ),
      ),
    );
  }
}
