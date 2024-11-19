import 'package:flutter/material.dart';
import 'package:parking_user/screens/manage_account.dart';

List<String> list = <String>['Bil', 'Motorcykel', 'Annan'];

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  String dropdownValue = list.first;

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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Lägg till fordon',
              style: TextStyle(fontSize: 24, color: Colors.deepOrangeAccent),
            ),
            const SizedBox(height: 100),
            TextField(
              decoration: InputDecoration(
                label: const Text('Ange registreringsnummer'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      width: 0.8,
                      color: Colors.deepOrangeAccent,
                    )),
              ),
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
                      color: Colors.deepOrangeAccent,
                    )),
              ),
              style: const TextStyle(color: Colors.deepOrange),
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
                  onPressed: setHomePageState,
                  child: const Text('Avbryt'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: setHomePageState,
                  child: const Text('Lägg till'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
