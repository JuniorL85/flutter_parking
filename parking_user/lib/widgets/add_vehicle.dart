import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/vehicle_bloc.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:provider/provider.dart';

List<String> list = <String>['Bil', 'Motorcykel', 'Annan'];

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final formKey = GlobalKey<FormState>();
  String dropdownValue = list.first;
  String? regNr;
  List<Vehicle> vehicleList = [];
  StreamSubscription? _blocSubscription;
  StreamSubscription? vehicleSubscription;
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
                  'Lägg till fordon',
                  style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                const SizedBox(height: 50),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ange ett registreringsnummer";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Ange registreringsnummer'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 0.8,
                        )),
                  ),
                  onChanged: (value) => regNr = value,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down_sharp),
                  elevation: 16,
                  decoration: InputDecoration(
                    label: const Text('Fordonstyp'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 0.8,
                        )),
                  ),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary),
                  onChanged: (String? value) {
                    setState(() {
                      dropdownValue = value!;
                    });
                  },
                  items: list.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                        if (formKey.currentState!.validate()) {
                          final index = vehicleList.indexWhere((v) =>
                              v.regNr.toUpperCase() == regNr!.toUpperCase());

                          if (index == -1) {
                            if (context.mounted) {
                              final bloc = context.read<VehicleBloc>();

                              _blocSubscription = bloc.stream.listen((state) {
                                if (state is VehiclesLoaded) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.lightGreen,
                                      content: Text(
                                          'Du har lagt till ett nytt fordon!'),
                                    ),
                                  );

                                  formKey.currentState?.reset();
                                  Navigator.of(context).pop();
                                } else if (state is VehiclesError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.redAccent,
                                      content: Text(state.message),
                                    ),
                                  );
                                }
                              });
                              context.read<VehicleBloc>().add(CreateVehicle(
                                  vehicle: Vehicle(
                                      regNr: regNr!,
                                      vehicleType: dropdownValue,
                                      owner: Person(
                                        id: person.id,
                                        name: person.name,
                                        socialSecurityNumber:
                                            person.socialSecurityNumber,
                                      ))));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                    'Det angivna registreringsnumret finns redan i listan'),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: const Text('Lägg till'),
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
