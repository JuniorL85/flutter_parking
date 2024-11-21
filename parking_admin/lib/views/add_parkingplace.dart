import 'package:flutter/material.dart';

class AddParkingplace extends StatefulWidget {
  const AddParkingplace({super.key});

  @override
  State<AddParkingplace> createState() => _AddParkingplaceState();
}

class _AddParkingplaceState extends State<AddParkingplace> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Lägg till parkeringsplats',
            style: TextStyle(fontSize: 24, color: Colors.blueGrey),
          ),
          const SizedBox(height: 70),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                label: const Text(
                  'Ange adress',
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
          const SizedBox(height: 10),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                label: const Text(
                  'Ange timpris',
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(seconds: 3),
                  backgroundColor: Colors.lightGreen,
                  content: Text('Du har lagt till en ny parkeringsplats!'),
                ),
              );
            },
            child: const Text('Lägg till'),
          )
        ],
      ),
    );
  }
}
