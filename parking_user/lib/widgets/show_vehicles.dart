import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dina fordon"),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: getVehicles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var vehicle = snapshot.data![index];
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: Colors.deepOrange.shade100,
                      child: Center(child: Text(vehicle.id.toString())),
                    ),
                    title: Text(
                      vehicle.regNr,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    trailing: getIcon(vehicle.vehicleType),
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
