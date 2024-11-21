import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class AddParkingplace extends StatefulWidget {
  const AddParkingplace({super.key});

  @override
  State<AddParkingplace> createState() => _AddParkingplaceState();
}

class _AddParkingplaceState extends State<AddParkingplace> {
  final _addressController = TextEditingController();
  final _pricePerHourController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _pricePerHourController.dispose();
    super.dispose();
  }

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
              controller: _addressController,
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
              controller: _pricePerHourController,
              keyboardType: TextInputType.number,
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
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _addressController,
            builder: (context, value, child) {
              return ElevatedButton(
                onPressed: value.text.isNotEmpty
                    ? () async {
                        if (validateNumber(_pricePerHourController.text)) {
                          final res = await ParkingSpaceRepository.instance
                              .addParkingSpace(
                            ParkingSpace(
                              address: _addressController.text,
                              pricePerHour:
                                  int.parse(_pricePerHourController.text),
                            ),
                          );
                          if (res.statusCode == 200) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.lightGreen,
                                  content: Text(
                                      'Du har lagt till en ny parkeringsplats!'),
                                ),
                              );
                            }
                            _addressController.clear();
                            _pricePerHourController.clear();
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                      'Något gick fel vänligen försök igen senare'),
                                ),
                              );
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                    'Du måste ange pris per timme i siffror!'),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: const Text('Lägg till'),
              );
            },
          )
        ],
      ),
    );
  }
}
