import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/person_bloc.dart';
import 'package:parking_user/bloc/vehicle_bloc.dart';

List<String> list = <String>['Bil', 'Motorcykel', 'Annan'];

class UpdateVehicle extends StatefulWidget {
  const UpdateVehicle({super.key});

  @override
  State<UpdateVehicle> createState() => _UpdateVehicleState();
}

class _UpdateVehicleState extends State<UpdateVehicle> {
  final formKey = GlobalKey<FormState>();
  bool isRegNrPicked = false;
  List<Vehicle> vehicleList = [];
  var _selectedRegNr;
  String dropdownValue = '';
  StreamSubscription? _blocSubscription;
  StreamSubscription? vehicleSubscription;
  late Person person;

  @override
  void initState() {
    super.initState();
    getVehicleListAndPerson();
  }

  @override
  void dispose() {
    vehicleSubscription?.cancel();
    _blocSubscription?.cancel();
    super.dispose();
  }

  getVehicleListAndPerson() async {
    if (mounted) {
      final personState = context.read<PersonBloc>().state;
      if (personState is PersonLoaded) {
        person = personState.person;

        final vehicleState = context.read<VehicleBloc>().state;
        if (vehicleState is! VehiclesLoaded) {
          context.read<VehicleBloc>().add(LoadVehiclesByPerson(person: person));
        } else {
          setState(() {
            vehicleList = vehicleState.vehicles;
          });
        }

        vehicleSubscription =
            context.read<VehicleBloc>().stream.listen((state) {
          if (state is VehiclesLoaded) {
            setState(() {
              vehicleList = state.vehicles;
            });
          }
        });
      }
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
                  'Uppdatera fordon',
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
                const SizedBox(height: 10),
                if (isRegNrPicked)
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
                    if (!isRegNrPicked)
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            dropdownValue = vehicleList
                                .where((vehicle) =>
                                    vehicle.regNr == _selectedRegNr)
                                .first
                                .vehicleType;
                            isRegNrPicked = true;
                          });
                        },
                        child: const Text('Välj fordon att uppdatera'),
                      ),
                    if (isRegNrPicked)
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final index = vehicleList.indexWhere(
                                (vehicle) => vehicle.regNr == _selectedRegNr);

                            if (index != -1) {
                              if (context.mounted) {
                                final bloc = context.read<VehicleBloc>();

                                _blocSubscription = bloc.stream.listen((state) {
                                  if (state is VehiclesLoaded) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 3),
                                        backgroundColor: Colors.lightGreen,
                                        content: Text(
                                            'Du har uppdaterat fordon med registreringsnummer $_selectedRegNr'),
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
                                context.read<VehicleBloc>().add(UpdateVehicles(
                                    vehicle: Vehicle(
                                        id: vehicleList[index].id,
                                        regNr: _selectedRegNr,
                                        vehicleType: dropdownValue,
                                        owner: Person(
                                          id: person.id,
                                          name: person.name,
                                          socialSecurityNumber:
                                              person.socialSecurityNumber,
                                        ))));
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
                        },
                        child: const Text('Uppdatera valt fordon'),
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
