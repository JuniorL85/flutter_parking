import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class DeleteParkingplace extends StatefulWidget {
  const DeleteParkingplace({super.key});

  @override
  State<DeleteParkingplace> createState() => _DeleteParkingplaceState();
}

class _DeleteParkingplaceState extends State<DeleteParkingplace> {
  final formKey = GlobalKey<FormState>();
  String? idToDelete;
  List<ParkingSpace> parkingSpaceList = [];

  @override
  void initState() {
    super.initState();
    getParkingSpaceList();
  }

  getParkingSpaceList() async {
    parkingSpaceList =
        await ParkingSpaceRepository.instance.getAllParkingSpaces();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'Ta bort parkeringsplats',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ange ett id";
                  }
                  return null;
                },
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
                onChanged: (value) => idToDelete = value,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final index = parkingSpaceList
                      .indexWhere((i) => i.id == int.parse(idToDelete!));

                  if (index != -1) {
                    final res = await ParkingSpaceRepository.instance
                        .deleteParkingSpace(parkingSpaceList[index]);

                    if (res.statusCode == 200) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.lightGreen,
                            content: Text(
                                'Du har raderat parkeringsplats med id: $idToDelete'),
                          ),
                        );
                      }
                      formKey.currentState?.reset();
                      setState(() {
                        getParkingSpaceList();
                      });
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
                              'Finns ingen parkeringsplats med angivet id'),
                        ),
                      );
                    }
                    formKey.currentState?.reset();
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
              child: const Text('Ta bort'),
            )
          ],
        ),
      ),
    );
  }
}
