import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/vehicle_bloc.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:provider/provider.dart';

class DeleteVehicle extends StatefulWidget {
  const DeleteVehicle({super.key});

  @override
  State<DeleteVehicle> createState() => _DeleteVehicleState();
}

class _DeleteVehicleState extends State<DeleteVehicle> {
  final formKey = GlobalKey<FormState>();
  Vehicle? vehicles;
  List<Vehicle> vehicleList = [];
  var _selectedRegNr;
  StreamSubscription? vehicleSubscription;
  StreamSubscription? _blocSubscription;
  late Person person;

  @override
  void initState() {
    super.initState();
    getVehicleList();
  }

  @override
  void dispose() {
    vehicleSubscription?.cancel();
    _blocSubscription?.cancel();
    super.dispose();
  }

  getVehicleList() async {
    if (mounted) {
      person = super.context.read<GetPerson>().person;
      context.read<VehicleBloc>().add(LoadVehiclesByPerson(person: person));
      vehicleSubscription = context.read<VehicleBloc>().stream.listen((state) {
        if (state is VehiclesLoaded) {
          setState(() {
            vehicleList = state.vehicles;

            if (vehicleList.isNotEmpty) {
              _selectedRegNr = vehicleList.first.regNr;
            } else {
              _selectedRegNr = null;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Radera fordon',
                  style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                const SizedBox(height: 50),
                DropdownButtonFormField(
                  isExpanded: true,
                  value: _selectedRegNr,
                  icon: const Icon(Icons.arrow_drop_down_sharp),
                  elevation: 16,
                  decoration: InputDecoration(
                    label: const Text('Registreringsnummer'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 0.8,
                        )),
                  ),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegNr = value!;
                    });
                  },
                  items: [
                    for (final vehicle in vehicleList)
                      DropdownMenuItem(
                        value: vehicle.regNr,
                        child: Text(
                          vehicle.regNr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Avbryt'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final savedRegNr;
                        if (formKey.currentState!.validate()) {
                          final index = vehicleList.indexWhere(
                              (vehicle) => vehicle.regNr == _selectedRegNr);

                          if (index != -1) {
                            if (context.mounted) {
                              savedRegNr = _selectedRegNr;
                              print(savedRegNr);
                              final bloc = context.read<VehicleBloc>();

                              _blocSubscription = bloc.stream.listen((state) {
                                if (state is VehiclesLoaded) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.lightGreen,
                                      content: Text(
                                          'Du har raderat fordon med registreringsnummer $savedRegNr'),
                                    ),
                                  );

                                  formKey.currentState?.reset();
                                  vehicleList = state.vehicles;
                                  if (vehicleList.isNotEmpty) {
                                    _selectedRegNr = vehicleList.first.regNr;
                                  } else {
                                    _selectedRegNr = null;
                                  }
                                } else if (state is VehiclesError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.redAccent,
                                      content: Text(
                                          'Något gick fel vänligen försök igen senare'),
                                    ),
                                  );
                                }
                              });
                              context.read<VehicleBloc>().add(DeleteVehicles(
                                  vehicle: Vehicle(
                                      id: vehicleList[index].id,
                                      regNr: _selectedRegNr,
                                      vehicleType:
                                          vehicleList[index].vehicleType,
                                      owner: Person(
                                        id: person.id,
                                        name: person.name,
                                        socialSecurityNumber:
                                            person.socialSecurityNumber,
                                      ))));

                              Navigator.of(context).pop();
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                      'Något är fel med valt registreringsnummer'),
                                ),
                              );
                            }
                          }
                        }
                        // setHomePageState
                      },
                      child: const Text('Radera fordon'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
