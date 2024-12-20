import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_app_cli/utils/calculate.dart';
import 'package:parking_user/bloc/person_bloc.dart';
import 'package:parking_user/providers/get_parking_provider.dart';
import 'package:provider/provider.dart';

class ShowParkingHistory extends StatefulWidget {
  const ShowParkingHistory({super.key});

  @override
  State<ShowParkingHistory> createState() => _ShowParkingHistoryState();
}

class _ShowParkingHistoryState extends State<ShowParkingHistory> {
  late Person person;
  StreamSubscription? personSubscription;

  @override
  void initState() {
    super.initState();
    getPerson();
  }

  @override
  void dispose() {
    personSubscription?.cancel();
    super.dispose();
  }

  getPerson() {
    if (mounted) {
      final personState = context.read<PersonBloc>().state;
      if (personState is PersonLoaded) {
        person = personState.person;
      } else {
        person = Person(name: '', socialSecurityNumber: '');
      }
      personSubscription = context.read<PersonBloc>().stream.listen((state) {
        if (state is PersonLoaded) {
          setState(() {
            person = state.person;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Parking>> getParkings =
        context.read<GetParking>().getAllParkings();

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
                  'Din parkeringshistorik',
                  style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
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
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: formattedSnapshot.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        var parking = formattedSnapshot[index];
                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ListTile(
                              leading:
                                  Text(parking.parkingSpace!.id.toString()),
                              title: Text(
                                parking.parkingSpace!.address,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              subtitle: Text(
                                  '${DateFormat('yyyy-MM-dd kk:mm').format(parking.startTime)} - ${DateFormat('yyyy-MM-dd kk:mm').format(parking.endTime)}'),
                              trailing: Text(
                                  '${calculateDuration(parking.startTime, parking.endTime, parking.parkingSpace!.pricePerHour).toStringAsFixed(2)} kr'),
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
