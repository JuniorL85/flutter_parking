import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class AddParkingplace extends StatefulWidget {
  const AddParkingplace({super.key});

  @override
  State<AddParkingplace> createState() => _AddParkingplaceState();
}

class _AddParkingplaceState extends State<AddParkingplace> {
  final formKey = GlobalKey<FormState>();
  String? address;
  String? pricePerHour;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const Text(
              'Lägg till parkeringsplats',
              style: TextStyle(fontSize: 24, color: Colors.blueGrey),
            ),
            const SizedBox(height: 70),
            SizedBox(
              width: 300,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ange en adress";
                  }
                  return null;
                },
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
                onChanged: (value) => address = value,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ange ett timpris";
                  }
                  return null;
                },
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
                onChanged: (value) => pricePerHour = value,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (validateNumber(pricePerHour!)) {
                    final res =
                        await ParkingSpaceRepository.instance.addParkingSpace(
                      ParkingSpace(
                        address: address!,
                        pricePerHour: int.parse(pricePerHour!),
                      ),
                    );
                    if (res.statusCode == 200) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.lightGreen,
                            content:
                                Text('Du har lagt till en ny parkeringsplats!'),
                          ),
                        );
                      }
                      formKey.currentState?.reset();
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
                          content:
                              Text('Du måste ange pris per timme i siffror!'),
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
                        content:
                            Text('Något gick fel vänligen försök igen senare'),
                      ),
                    );
                  }
                  return;
                }
              },
              child: const Text('Lägg till'),
            ),
          ],
        ),
      ),
    );
  }
}
