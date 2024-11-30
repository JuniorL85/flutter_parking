import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class ShowVehicles extends StatelessWidget {
  const ShowVehicles({super.key, this.person});

  final Person? person;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dina fordon"),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: getVehicles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var formattedSnapshot = snapshot.data!
                .where((vehicle) =>
                    vehicle.owner!.socialSecurityNumber ==
                    person!.socialSecurityNumber)
                .toList();
            return ListView.builder(
                itemCount: formattedSnapshot.length,
                itemBuilder: (context, index) {
                  var vehicle = formattedSnapshot[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                        leading: getIcon(vehicle.vehicleType),
                        title: Text(
                          vehicle.regNr,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        tileColor: Colors.deepOrange.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.deepOrange.shade300),
                        )),
                  );
                });
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
