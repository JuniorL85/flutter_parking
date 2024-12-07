import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/providers/get_vehicle_provider.dart';
import 'package:provider/provider.dart';

class DeleteVehicle extends StatefulWidget {
  const DeleteVehicle({super.key});

  @override
  State<DeleteVehicle> createState() => _DeleteVehicleState();
}

class _DeleteVehicleState extends State<DeleteVehicle> {
  final formKey = GlobalKey<FormState>();
  Vehicle? vehicles;
  late List<Vehicle> vehicleList = [];
  var _selectedRegNr;

  @override
  void initState() {
    super.initState();
    getVehicleList();
  }

  getVehicleList() async {
    if (mounted) {
      Person person = super.context.read<GetPerson>().person;
      List<Vehicle> list =
          await super.context.read<GetVehicle>().getAllVehicles();
      vehicleList = list
          .where((vehicle) =>
              vehicle.owner!.socialSecurityNumber ==
              person.socialSecurityNumber)
          .toList();
      setState(() {
        _selectedRegNr = vehicleList.first.regNr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Person person = context.read<GetPerson>().person;
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
                        if (formKey.currentState!.validate()) {
                          final index = vehicleList.indexWhere(
                              (vehicle) => vehicle.regNr == _selectedRegNr);

                          if (index != -1) {
                            final res =
                                await VehicleRepository.instance.deleteVehicle(
                              Vehicle(
                                id: vehicleList[index].id,
                                regNr: _selectedRegNr,
                                vehicleType: vehicleList[index].vehicleType,
                                owner: Person(
                                  id: person.id,
                                  name: person.name,
                                  socialSecurityNumber:
                                      person.socialSecurityNumber,
                                ),
                              ),
                            );
                            if (res.statusCode == 200) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Colors.lightGreen,
                                    content: Text(
                                        'Du har raderat fordon med registreringsnummer $_selectedRegNr'),
                                  ),
                                );
                                formKey.currentState?.reset();
                                Navigator.of(context).pop();
                              }
                            } else {
                              if (context.mounted) {
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
