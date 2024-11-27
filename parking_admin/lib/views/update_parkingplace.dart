import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class UpdateParkingplace extends StatefulWidget {
  const UpdateParkingplace({super.key});

  @override
  State<UpdateParkingplace> createState() => _UpdateParkingplaceState();
}

class _UpdateParkingplaceState extends State<UpdateParkingplace> {
  final formKey = GlobalKey<FormState>();
  bool isId = false;
  String? idToUpdate;
  String? address;
  String? pricePerHour;
  List<ParkingSpace> parkingSpaceList = [];
  ParkingSpace? chosenParkingSpace;

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
            const Text(
              'Uppdatera parkeringsplats',
              style: TextStyle(fontSize: 24, color: Colors.blueGrey),
            ),
            const SizedBox(height: 70),
            if (!isId)
              Column(
                children: [
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
                      onChanged: (value) => idToUpdate = value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final formattedParkingSpaceId = int.parse(idToUpdate!);
                        final index = parkingSpaceList
                            .indexWhere((i) => i.id == formattedParkingSpaceId);

                        if (index != -1) {
                          chosenParkingSpace = await ParkingSpaceRepository
                              .instance
                              .getParkingSpaceById(formattedParkingSpaceId);
                          setState(() {
                            formKey.currentState?.reset();
                            isId = true;
                          });
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
                            formKey.currentState?.reset();
                          }
                        }
                      }
                    },
                    child: const Text('Hämta parkeringsplats'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                        key: Key(chosenParkingSpace!.address),
                        initialValue: chosenParkingSpace!.address,
                        autovalidateMode: AutovalidateMode.always,
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
                        onSaved: (value) => address = value,
                        onChanged: (value) => address = value),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      key: Key(chosenParkingSpace!.pricePerHour.toString()),
                      initialValue: chosenParkingSpace!.pricePerHour.toString(),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ange ett timpris";
                        }
                        return null;
                      },
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
                      onSaved: (value) => pricePerHour = value,
                      onChanged: (value) => pricePerHour = value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          formKey.currentState!.save();
                          print(address);
                          print(pricePerHour);
                          print(chosenParkingSpace!.id);
                          isId = false;
                        });
                      }
                    },
                    child: const Text('Uppdatera parkeringsplats'),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
