import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class DeleteVehicle extends StatefulWidget {
  const DeleteVehicle({super.key, required this.person});

  final Person? person;

  @override
  State<DeleteVehicle> createState() => _DeleteVehicleState();
}

class _DeleteVehicleState extends State<DeleteVehicle> {
  final formKey = GlobalKey<FormState>();
  Vehicle? vehicles;
  List<Vehicle> vehicleList = [];

  @override
  void initState() {
    super.initState();
    getVehicleList();
  }

  getVehicleList() async {
    List<Vehicle> list = await VehicleRepository.instance.getAllVehicles();
    vehicleList = list
        .where((vehicle) =>
            vehicle.owner!.socialSecurityNumber ==
            widget.person!.socialSecurityNumber)
        .toList();
    print('hej: ${vehicleList[0].id}');
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
                const Text(
                  'Radera fordon',
                  style:
                      TextStyle(fontSize: 24, color: Colors.deepOrangeAccent),
                ),
                const SizedBox(height: 100),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: vehicleList[0].regNr,
                  icon: const Icon(Icons.arrow_drop_down_sharp),
                  elevation: 16,
                  decoration: InputDecoration(
                    label: const Text('Fordonstyp'),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 0.8,
                          color: Colors.deepOrangeAccent,
                        )),
                  ),
                  style: const TextStyle(color: Colors.deepOrange),
                  onChanged: (String? value) {
                    setState(() {
                      vehicleList[0].id = value;
                    });
                  },
                  items: vehicleList
                      .map<DropdownMenuItem<Vehicle>>((Vehicle value) {
                    return DropdownMenuItem<Vehicle>(
                      value: value,
                      child: Text(value.regNr),
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
                          final res =
                              await VehicleRepository.instance.deleteVehicle(
                            Vehicle(
                              id: vehicles!.id,
                              regNr: vehicles!.regNr,
                              vehicleType: vehicles!.vehicleType,
                              owner: Person(
                                id: widget.person!.id,
                                name: widget.person!.name,
                                socialSecurityNumber:
                                    widget.person!.socialSecurityNumber,
                              ),
                            ),
                          );
                          if (res.statusCode == 200) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: Colors.lightGreen,
                                  content: Text(
                                      'Du har raderat fordon med registreringsnummer ${vehicles!.regNr}'),
                                ),
                              );
                            }
                            formKey.currentState?.reset();
                            Navigator.of(context).pop();
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
                        }
                        // setHomePageState
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
