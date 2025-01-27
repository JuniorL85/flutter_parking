import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_admin/bloc/parking_bloc.dart';

class Monitoring extends StatefulWidget {
  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  List<Parking> activeParkingsList = [];
  List<Parking> mostPopularParkings = [];
  Map<int, int> mapData = {};
  StreamSubscription? activeParkingsSubscription;
  StreamSubscription? popularParkingsSubscription;

  @override
  void initState() {
    super.initState();
    setActiveParkingsList();
    setMostPopularParkingSpaces();
  }

  @override
  void dispose() {
    activeParkingsSubscription?.cancel();
    popularParkingsSubscription?.cancel();
    super.dispose();
  }

  void setActiveParkingsList() {
    context.read<ActiveParkingBloc>().add(LoadActiveParkings());
    activeParkingsSubscription =
        context.read<ActiveParkingBloc>().stream.listen((state) {
      if (state is ActiveParkingsLoaded) {
        setState(() {
          activeParkingsList = state.activeParkings;
        });
      }
    });
  }

  void setMostPopularParkingSpaces() {
    context.read<ParkingBloc>().add(LoadParkings());

    popularParkingsSubscription =
        context.read<ParkingBloc>().stream.listen((state) {
      if (state is ParkingsLoaded) {
        mapData.clear();
        for (var parking in state.parkings) {
          final parkingSpaceId = parking.parkingSpace?.id;
          if (parkingSpaceId != null) {
            mapData[int.parse(parkingSpaceId)] =
                (mapData[int.parse(parkingSpaceId)] ?? 0) + 1;
          }
        }
        if (mapData.isNotEmpty) {
          int maxCount =
              mapData.values.fold(0, (prev, curr) => curr > prev ? curr : prev);

          List<int> mostPopularIds = mapData.entries
              .where((entry) => entry.value == maxCount)
              .map((entry) => entry.key)
              .toList();

          Map<int, Parking> uniqueMostPopularParkings = {};
          for (var parking in state.parkings) {
            final parkingSpaceId = parking.parkingSpace?.id;
            if (parkingSpaceId != null &&
                mostPopularIds.contains(int.parse(parkingSpaceId))) {
              uniqueMostPopularParkings[int.parse(parkingSpaceId)] = parking;
            }
          }
          setState(() {
            mostPopularParkings = uniqueMostPopularParkings.values.toList();
          });
        }
      }
    });
  }

  String _calculateActiveSum() {
    double sum = 0;
    for (var parking in activeParkingsList) {
      sum += calculateDuration(
        parking.startTime,
        parking.endTime,
        parking.parkingSpace!.pricePerHour,
      );
    }
    return sum.toStringAsFixed(2);
  }

  updateTheme() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.center,
        colors: <Color>[
          Theme.of(context).colorScheme.onInverseSurface,
          Theme.of(context).colorScheme.inversePrimary
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Övervakning',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                mainAxisExtent: 120,
              ),
              itemCount: 3,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    color: Colors.transparent,
                    child: Container(
                      decoration: updateTheme(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.summarize_outlined),
                            title: const Text('Total summa aktiva parkeringar'),
                            subtitle: Text('${_calculateActiveSum()} kr'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (index == 1) {
                  return Card(
                    color: Colors.transparent,
                    child: Container(
                      decoration: updateTheme(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.local_parking_sharp),
                            title: const Text('Populäraste parkeringsplatsen'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: mostPopularParkings.map((parking) {
                                return Text(
                                  'Id: ${parking.parkingSpace?.id}, '
                                  'Adress: ${parking.parkingSpace?.address}, '
                                  'Parkerad på: ${mapData[int.tryParse(parking.parkingSpace!.id)]}',
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    color: Colors.transparent,
                    child: Container(
                      decoration: updateTheme(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading:
                                const Icon(Icons.notifications_active_sharp),
                            title: const Text('Antal aktiva'),
                            subtitle: Text('${activeParkingsList.length} st'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
          const SizedBox(height: 20),
          SizedBox(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      activeParkingsList.sort((a, b) => a
                          .parkingSpace!.pricePerHour
                          .toString()
                          .compareTo(b.parkingSpace!.pricePerHour.toString()));
                    });
                  },
                  child: const Text('Sortera på stigande pris'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      activeParkingsList.sort((a, b) => b
                          .parkingSpace!.pricePerHour
                          .toString()
                          .compareTo(a.parkingSpace!.pricePerHour.toString()));
                    });
                  },
                  child: const Text('Sortera på fallande pris'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      activeParkingsList.sort((a, b) => a.parkingSpace!.address
                          .compareTo(b.parkingSpace!.address));
                    });
                  },
                  child: const Text('Sortera på adress stigande'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      activeParkingsList.sort((a, b) => b.parkingSpace!.address
                          .compareTo(a.parkingSpace!.address));
                    });
                  },
                  child: const Text('Sortera på adress fallande'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      activeParkingsList.sort((a, b) => a.id.compareTo(b.id));
                    });
                  },
                  child: const Text('Sortera på id stigande'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      activeParkingsList.sort((a, b) => b.id.compareTo(a.id));
                    });
                  },
                  child: const Text('Sortera på id fallande'),
                )
              ],
            ),
          ),
          BlocBuilder<ActiveParkingBloc, ActiveParkingState>(
            builder: (context, parkingState) {
              if (parkingState is ActiveParkingInitial ||
                  parkingState is ActiveParkingsLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (parkingState is ActiveParkingsLoaded) {
                Widget content = activeParkingsList.isEmpty
                    ? const Expanded(
                        child: Center(
                        child: Text(
                            'Finns inga aktiva parkeringar att visa just nu.'),
                      ))
                    : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: activeParkingsList.length,
                          itemBuilder: (context, index) {
                            var activeParking = activeParkingsList[index];
                            return ListTile(
                              title: SizedBox(
                                height: 210,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Id: ${activeParking.id}'),
                                    Text(
                                        'Adress: ${activeParking.parkingSpace?.address}'),
                                    Text(
                                        'Pris: ${activeParking.parkingSpace?.pricePerHour.toString()}kr/h'),
                                    Text(
                                        'Från: ${DateFormat('yyyy-MM-dd kk:mm').format(activeParking.startTime)} - Till: ${DateFormat('yyyy-MM-dd kk:mm').format(activeParking.endTime)}'),
                                    Text(
                                        'Fordon: ${activeParking.vehicle?.regNr}'),
                                    Text('Summa: ${calculateDuration(
                                      activeParking.startTime,
                                      activeParking.endTime,
                                      activeParking.parkingSpace!.pricePerHour,
                                    ).toStringAsFixed(2)} kr'),
                                    const Divider(thickness: 1, height: 5),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                return content;
              } else if (parkingState is ActiveParkingsError) {
                return Text('Error: ${parkingState.message}');
              } else {
                return const Text('Ingen data tillgänglig');
              }
            },
          ),
        ],
      ),
    );
  }
}
