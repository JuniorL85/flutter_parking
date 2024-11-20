import 'package:flutter/material.dart';

class DeleteParkingplace extends StatelessWidget {
  const DeleteParkingplace({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Ta bort parkeringsplats',
            style: TextStyle(fontSize: 24, color: Colors.blueGrey),
          ),
          const SizedBox(height: 70),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                label: const Text(
                  'Ange id för parkeringsplats du vill ta bort',
                  style: TextStyle(fontSize: 14),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      width: 0.8,
                      color: Colors.blueGrey,
                    )),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Ta bort'),
          )
        ],
      ),
    );
  }
}
