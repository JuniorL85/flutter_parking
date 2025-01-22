import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/bloc/vehicle/vehicle_bloc.dart';

class ShowVehicles extends StatefulWidget {
  const ShowVehicles({super.key});

  @override
  State<ShowVehicles> createState() => _ShowVehiclesState();
}

class _ShowVehiclesState extends State<ShowVehicles> {
  List<Vehicle> vehicleList = [];
  late Person person;
  StreamSubscription? vehicleSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getVehicleListAndPerson();
  }

  @override
  void dispose() {
    vehicleSubscription?.cancel();
    super.dispose();
  }

  getVehicleListAndPerson() async {
    if (mounted) {
      final personState = context.read<PersonBloc>().state;
      if (personState is PersonLoaded) {
        person = personState.person;

        context.read<VehicleBloc>().add(LoadVehiclesByPerson(person: person));

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
          BlocBuilder<VehicleBloc, VehicleState>(
            builder: (context, state) {
              if (state is VehiclesInitial || state is VehiclesLoading) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              } else if (state is VehiclesLoaded) {
                Widget content = vehicleList.isEmpty
                    ? const Expanded(
                        child: Center(
                        child: Text(
                            'Finns inga fordon att visa, lägg till fordon'),
                      ))
                    : Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: vehicleList.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              var vehicle = vehicleList[index];
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
                                    tileColor: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
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
                return content;
              } else if (state is VehiclesError) {
                return Text('Error: ${state.message}');
              } else {
                return const Text('Ingen data tillgänglig');
              }
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
