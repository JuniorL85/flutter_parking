import 'package:flutter/material.dart';

class UpdateParkingplace extends StatefulWidget {
  const UpdateParkingplace({super.key});

  @override
  State<UpdateParkingplace> createState() => _UpdateParkingplaceState();
}

class _UpdateParkingplaceState extends State<UpdateParkingplace> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Uppdatera parkeringsplats',
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
            onPressed: () {},
            child: const Text('Uppdatera'),
          )
        ],
      ),
    );
  }
}
