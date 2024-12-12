import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:provider/provider.dart';

class ShowVehicles extends StatelessWidget {
  const ShowVehicles({super.key});

  getIcon(String type) {
    switch (type) {
      case 'Bil':
      case 'Car':
        return const Icon(Icons.directions_car_filled_outlined);
      case 'Motorcykel':
      case 'Motorcycle':
        return const Icon(Icons.motorcycle_outlined);
      case 'Annan':
      case 'Other':
        return const Icon(Icons.track_changes_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Vehicle>> getVehicles =
        VehicleRepository.instance.getAllVehicles();

    final person = context.read<GetPerson>().person;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dina fordon',
                  style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
              ],
            ),
          ),
          FutureBuilder<List<Vehicle>>(
            future: getVehicles,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var formattedSnapshot = snapshot.data!
                    .where((vehicle) =>
                        vehicle.owner!.socialSecurityNumber ==
                        person.socialSecurityNumber)
                    .toList();
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: formattedSnapshot.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        var vehicle = formattedSnapshot[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                              leading: getIcon(vehicle.vehicleType),
                              title: Text(
                                vehicle.regNr,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              tileColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                              )),
                        );
                      }),
                );
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
      floatingActionButton: TextButton.icon(
        label: const Text('Tillbaka'),
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
