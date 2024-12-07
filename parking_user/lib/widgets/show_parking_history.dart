import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_app_cli/utils/calculate.dart';
import 'package:parking_user/providers/get_parking_provider.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:provider/provider.dart';

class ShowParkingHistory extends StatelessWidget {
  const ShowParkingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    Future<List<Parking>> getParkings =
        context.read<GetParking>().getAllParkings();

    final person = context.read<GetPerson>().person;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Din parkeringshistorik',
                  style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                TextButton.icon(
                  label: const Text('Tillbaka'),
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ),
          FutureBuilder<List<Parking>>(
            future: getParkings,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var formattedSnapshot = snapshot.data!
                    .where((parking) =>
                        parking.vehicle?.owner?.socialSecurityNumber ==
                            person.socialSecurityNumber &&
                        parking.endTime.microsecondsSinceEpoch <
                            DateTime.now().microsecondsSinceEpoch)
                    .toList();
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: formattedSnapshot.length,
                    itemBuilder: (context, index) {
                      var parking = formattedSnapshot[index];
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ListTile(
                            leading: Text(
                                '${calculateDuration(parking.startTime, parking.endTime, parking.parkingSpace!.pricePerHour).toStringAsFixed(2)} kr'),
                            title: Text(
                              '${parking.parkingSpace!.id.toString()} - ${parking.parkingSpace!.address}',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            subtitle: Text(
                                '${DateFormat('yyyy-MM-dd kk:mm').format(parking.startTime)} - ${DateFormat('yyyy-MM-dd kk:mm').format(parking.endTime)}'),
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
                    });
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
