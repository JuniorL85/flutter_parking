import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_user/bloc/parking/parking_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';

class ShowParkingHistory extends StatefulWidget {
  const ShowParkingHistory({super.key});

  @override
  State<ShowParkingHistory> createState() => _ShowParkingHistoryState();
}

class _ShowParkingHistoryState extends State<ShowParkingHistory> {
  late Person person;
  List<Parking> parkingList = [];
  StreamSubscription? personSubscription;
  StreamSubscription? parkingSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ParkingBloc>().add(LoadNonActiveParkings());
    getPersonAndNonActiveParkings();
  }

  @override
  void dispose() {
    personSubscription?.cancel();
    parkingSubscription?.cancel();
    super.dispose();
  }

  getPersonAndNonActiveParkings() async {
    if (mounted) {
      final personState = context.read<PersonBloc>().state;
      if (personState is PersonLoaded) {
        person = personState.person;
        final parkingState = context.read<ParkingBloc>().state;
        if (parkingState is! ParkingsLoaded) {
          context.read<ParkingBloc>().add(LoadNonActiveParkings());
        } else {
          setState(() {
            parkingList = parkingState.parkings
                .where((parking) =>
                    parking.vehicle?.owner?.socialSecurityNumber ==
                    person.socialSecurityNumber)
                .toList();
            parkingList.sort((a, b) =>
                a.startTime.toString().compareTo(b.startTime.toString()));
          });
        }

        parkingSubscription =
            context.read<ParkingBloc>().stream.listen((state) {
          if (state is ParkingsLoaded) {
            setState(() {
              parkingList = state.parkings
                  .where((parking) =>
                      parking.vehicle?.owner?.socialSecurityNumber ==
                      person.socialSecurityNumber)
                  .toList();
              parkingList.sort((a, b) =>
                  a.startTime.toString().compareTo(b.startTime.toString()));
            });
          }
        });
      } else {
        person = Person(name: '', socialSecurityNumber: '', email: '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Parkeringshistorik',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Theme.of(context).colorScheme.onInverseSurface,
                  Theme.of(context).colorScheme.inversePrimary
                ]),
          ),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, state) {
              if (state is ParkingInitial || state is ParkingsLoading) {
                return const Expanded(
                    child: Center(child: CircularProgressIndicator()));
              } else if (state is ParkingsLoaded) {
                Widget content = parkingList.isEmpty
                    ? const Expanded(
                        child: Center(
                        child: Text('Finns ingen historik att visa'),
                      ))
                    : Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: parkingList.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              var parking = parkingList[index];
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.center,
                                        colors: <Color>[
                                          Colors.white38,
                                          Theme.of(context)
                                              .colorScheme
                                              .inversePrimary
                                        ]),
                                  ),
                                  child: ListTile(
                                      leading: Column(
                                        children: [
                                          Text(
                                            DateFormat('dd')
                                                .format(parking.startTime),
                                            style:
                                                const TextStyle(fontSize: 24),
                                          ),
                                          Text(DateFormat('MMM')
                                              .format(parking.startTime)),
                                        ],
                                      ),
                                      title: Text(
                                        parking.parkingSpace!.address,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ),
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.schedule_sharp),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                      '${DateFormat('kk:mm').format(parking.startTime)} - ${DateFormat('kk:mm').format(parking.endTime)}'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.tag),
                                                  Text(parking.parkingSpace!.id
                                                      .substring(0, 5)
                                                      .toString()),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.paid_sharp),
                                              const SizedBox(width: 5),
                                              Text(
                                                  '${calculateDuration(parking.startTime, parking.endTime, parking.parkingSpace!.pricePerHour).toStringAsFixed(2)} kr'),
                                            ],
                                          ),
                                        ],
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
                                ),
                              );
                            }),
                      );
                return content;
              } else if (state is ParkingsError) {
                return Text('Error: ${state.message}');
              } else {
                return const Text('Ingen data tillgänglig');
              }
            },
          ),
        ],
      ),
      // floatingActionButton: TextButton.icon(
      //   label: const Text('Tillbaka'),
      //   icon: const Icon(Icons.arrow_back),
      //   onPressed: () {
      //     Navigator.of(context).pop();
      //   },
      // ),
    );
  }
}
