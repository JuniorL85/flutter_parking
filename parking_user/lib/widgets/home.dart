import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Image.asset(
          'assets/images/parkHere1.png',
          fit: BoxFit.cover,
          opacity: const AlwaysStoppedAnimation(.1),
        ),
      ),
    );
  }
}
