import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/screens/manage_account.dart';

List<String> list = <String>['Bil', 'Motorcykel', 'Annan'];

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key, required this.person});

  final Person? person;

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final formKey = GlobalKey<FormState>();
  String dropdownValue = list.first;
  String? regNr;

  List<Person> personList = [];

  @override
  void initState() {
    super.initState();
    getpersonList();
  }

  getpersonList() async {
    personList = await PersonRepository.instance.getAllPersons();
  }

  setHomePageState() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ManageAccount(
          onSetNewState: (index) => index = 0,
        ),
      ),
    );
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
                const SizedBox(height: 100),
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
                          final res =
                              await VehicleRepository.instance.addVehicle(
                            Vehicle(
                              regNr: regNr!,
                              vehicleType: dropdownValue,
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
                                const SnackBar(
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.lightGreen,
                                  content:
                                      Text('Du har lagt till ett nytt fordon!'),
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
