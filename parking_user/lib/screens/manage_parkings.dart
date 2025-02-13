import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_user/bloc/notifications/notification_bloc.dart';
import 'package:parking_user/bloc/parking/parking_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/bloc/vehicle/vehicle_bloc.dart';
import 'package:parking_user/widgets/datepicker_parking.dart';
import 'package:parking_user/widgets/show_parking_history.dart';
import 'package:parking_user/widgets/start_parking.dart';

//ignore: must_be_immutable
class ManageParkings extends StatefulWidget {
  ManageParkings({super.key});

  bool isActiveParking = false;
  bool isScheduled = false;

  @override
  State<ManageParkings> createState() => _ManageParkingsState();
}

class _ManageParkingsState extends State<ManageParkings> {
  List<Parking> parkingList = [];
  int? foundActiveParking;
  late Person person;
  List<Vehicle> vehicleList = [];
  bool isLoading = true;
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);
  StreamSubscription? vehicleSubscription;
  StreamSubscription? personSubscription;
  StreamSubscription? parkingSubscription;
  StreamSubscription? _updateParkingSubscription;
  StreamSubscription? _deleteParkingSubscription;
  bool permission = false;
  String notificationId = '';

  @override
  void initState() {
    super.initState();
    requestPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) => findActiveParking());
    // AppLifecycleListener(
    //   onResume: () {
    //     if (!mounted) return;
    //     final lastActionVar =
    //         context.watch<NotificationBloc>().state.lastAction;
    //     print('lastAction $lastActionVar');
    //   },
    // );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    vehicleSubscription?.cancel();
    personSubscription?.cancel();
    parkingSubscription?.cancel();
    _updateParkingSubscription?.cancel();
    _deleteParkingSubscription?.cancel();
    super.dispose();
  }

  requestPermission() {
    if (permission == false) {
      context.read<NotificationBloc>().add(RequestPermission());
      findActiveParking();
    }
  }

  findActiveParking() async {
    if (!mounted) return;

    final personState = context.read<PersonBloc>().state;
    if (personState is PersonLoaded) {
      person = personState.person;

      context.read<VehicleBloc>().add(LoadVehiclesByPerson(person: person));
      final vehicleState =
          await context.read<VehicleBloc>().stream.firstWhere((state) {
        if (state is VehiclesLoading) {
          setState(() {
            isLoading = true;
          });
        }
        return state is VehiclesLoaded || state is VehiclesError;
      });

      if (vehicleState is VehiclesLoaded) {
        vehicleList = vehicleState.vehicles;
        setState(() {
          isLoading = false;
        });
      } else if (vehicleState is VehiclesError) {
        debugPrint('Fel vid laddning av fordon: ${vehicleState.message}');
        return;
      }

      if (!mounted) return;
      context.read<ParkingBloc>().add(LoadActiveParkings());
      final parkingState =
          await context.read<ParkingBloc>().stream.firstWhere((state) {
        if (state is ParkingsLoading) {
          setState(() {
            isLoading = true;
          });
        }
        return state is ActiveParkingsLoaded || state is ParkingsError;
      });

      if (parkingState is ActiveParkingsLoaded) {
        parkingList = parkingState.parkings;
        setState(() {
          isLoading = false;
        });
      } else if (parkingState is ParkingsError) {
        debugPrint(
            'Fel vid laddning av aktiva parkeringar: ${parkingState.message}');
        return;
      }

      final filteredParkings = parkingList.where((activeParking) {
        final matchingVehicle = vehicleList.any((v) =>
            v.regNr.toUpperCase() ==
            activeParking.vehicle!.regNr.toUpperCase());
        return matchingVehicle;
      }).toList();

      if (context.read<NotificationBloc>().state.permission != null) {
        permission = context.read<NotificationBloc>().state.permission!;
      }

      setState(() {
        parkingList = filteredParkings;
        foundActiveParking = parkingList.isEmpty ? -1 : 0;
        widget.isActiveParking = foundActiveParking != -1;

        if (foundActiveParking != -1 && permission == true) {
          notificationId = parkingList[foundActiveParking!].id;
          context.read<NotificationBloc>().add(ScheduleNotification(
              id: parkingList[foundActiveParking!].id,
              title: "Din parkering går ut om 15 min",
              content:
                  'Du är parkerad på: ${parkingList[foundActiveParking!].parkingSpace!.address}',
              deliveryTime: parkingList[foundActiveParking!]
                  .endTime
                  .add(const Duration(minutes: -15))));
        }
      });
    }
  }

  calculateActiveParking() {
    if (foundActiveParking == -1 || parkingList.isEmpty) {
      return const Text('Ingen aktiv parkering hittades.');
    }

    var price = calculateDuration(
      parkingList[foundActiveParking!].startTime,
      parkingList[foundActiveParking!].endTime,
      parkingList[foundActiveParking!].parkingSpace!.pricePerHour,
    );
    return Text('Ditt pris kommer att bli ${price.toStringAsFixed(2)} kr');
  }

  @override
  Widget build(BuildContext context) {
    Widget content = isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: Container(
              margin: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Text(
                    'Hantera parkering',
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    !widget.isActiveParking
                        ? 'Du har inga aktiva parkeringar, välj nedan vad du vill göra'
                        : 'Du har en aktiv parkering, välj nedan vad du vill göra',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  const SizedBox(height: 50),
                  if (!widget.isActiveParking)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              'Starta parkering',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            trailing: ConstrainedBox(
                              constraints:
                                  const BoxConstraints.tightFor(width: 120),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (ctx) => const StartParking(),
                                    ),
                                  )
                                      .then((onValue) async {
                                    await Future.delayed(
                                        const Duration(milliseconds: 100));
                                    setState(() {
                                      findActiveParking();
                                    });
                                  });
                                },
                                child: const Text('Starta'),
                              ),
                            ),
                            tileColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.isActiveParking && foundActiveParking != -1)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Column(
                            children: [
                              Text(
                                  'Du är parkerad på: ${parkingList[foundActiveParking!].parkingSpace!.address}'),
                              Text(
                                  'Parkeringen startade: ${DateFormat('yyyy-MM-dd kk:mm').format(parkingList[foundActiveParking!].startTime)}'),
                              Text(
                                  'Parkeringen avslutas: ${DateFormat('yyyy-MM-dd kk:mm').format(parkingList[foundActiveParking!].endTime)}'),
                              calculateActiveParking()
                            ],
                          ),
                          const SizedBox(height: 30),
                          ListTile(
                            title: Text(
                              'Uppdatera sluttid',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            trailing: ConstrainedBox(
                              constraints:
                                  const BoxConstraints.tightFor(width: 120),
                              child: ElevatedButton(
                                onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Uppdatera sluttid'),
                                    content: SizedBox(
                                      height: 120,
                                      child: Column(
                                        children: [
                                          const Text(
                                              'Välj datum och tid för att uppdatera din sluttid'),
                                          ValueListenableBuilder(
                                              valueListenable: _selectedDate,
                                              builder: (context, value, child) {
                                                return const Text('');
                                              }),
                                          Datepicker(
                                              parkingList[foundActiveParking!]
                                                  .startTime, (value) {
                                            setState(() {
                                              _selectedDate.value = value;
                                            });
                                          }),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Avbryt'),
                                        child: const Text('Avbryt'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (_selectedDate.value != null) {
                                            if (context.mounted) {
                                              final bloc =
                                                  context.read<ParkingBloc>();

                                              _updateParkingSubscription =
                                                  bloc.stream.listen((state) {
                                                if (state
                                                    is ActiveParkingsLoaded) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      duration:
                                                          Duration(seconds: 3),
                                                      backgroundColor:
                                                          Colors.lightGreen,
                                                      content: Text(
                                                          'Du har uppdaterat sluttiden på din parkering'),
                                                    ),
                                                  );

                                                  setState(() {
                                                    Navigator.pop(context);
                                                    findActiveParking();
                                                  });
                                                } else if (state
                                                    is ParkingsError) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      duration: const Duration(
                                                          seconds: 3),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      content:
                                                          Text(state.message),
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                }
                                              });
                                              context.read<ParkingBloc>().add(UpdateParking(
                                                  parking: Parking(
                                                      vehicle: Vehicle(
                                                          regNr: parkingList[foundActiveParking!]
                                                              .vehicle!
                                                              .regNr,
                                                          vehicleType:
                                                              parkingList[foundActiveParking!]
                                                                  .vehicle!
                                                                  .vehicleType,
                                                          owner: person),
                                                      parkingSpace: ParkingSpace(
                                                          id: parkingList[foundActiveParking!]
                                                              .parkingSpace!
                                                              .id,
                                                          creatorId:
                                                              parkingList[foundActiveParking!]
                                                                  .parkingSpace!
                                                                  .creatorId,
                                                          address:
                                                              parkingList[foundActiveParking!]
                                                                  .parkingSpace!
                                                                  .address,
                                                          pricePerHour:
                                                              parkingList[foundActiveParking!]
                                                                  .parkingSpace!
                                                                  .pricePerHour),
                                                      id: parkingList[foundActiveParking!]
                                                          .id,
                                                      startTime:
                                                          parkingList[foundActiveParking!].startTime,
                                                      endTime: _selectedDate.value!)));
                                            }
                                          } else {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  duration:
                                                      Duration(seconds: 3),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  content: Text(
                                                      'Du har inte valt korrekt datum och tid!'),
                                                ),
                                              );
                                              Navigator.pop(context);
                                            }
                                          }
                                        },
                                        child: BlocBuilder<ParkingBloc,
                                            ParkingState>(
                                          builder: (context, state) {
                                            if (state is ParkingsLoading) {
                                              return const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            }
                                            return const Text('Uppdatera');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: const Text('Uppdatera'),
                              ),
                            ),
                            tileColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                            ),
                          ),
                          const SizedBox(height: 5),
                          ListTile(
                            title: Text(
                              'Avsluta parkering',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            trailing: ConstrainedBox(
                              constraints:
                                  const BoxConstraints.tightFor(width: 120),
                              child: ElevatedButton(
                                onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('Avsluta parkering'),
                                    content: const Text(
                                        'Är du säker på att du vill avsluta din parkering? Det går inte att ångra efter att du tryckt på knappen "Avsluta".'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'Avbryt'),
                                        child: const Text('Avbryt'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          if (context.mounted) {
                                            final bloc =
                                                context.read<ParkingBloc>();

                                            final scaffoldMessenger =
                                                ScaffoldMessenger.of(context);

                                            _deleteParkingSubscription =
                                                bloc.stream.listen((state) {
                                              if (state
                                                  is ActiveParkingsLoaded) {
                                                context
                                                    .read<NotificationBloc>()
                                                    .add(CancelNotification(
                                                        id: notificationId));
                                                scaffoldMessenger.showSnackBar(
                                                  const SnackBar(
                                                    duration:
                                                        Duration(seconds: 3),
                                                    backgroundColor:
                                                        Colors.lightGreen,
                                                    content: Text(
                                                        'Du har avslutat din parkering!'),
                                                  ),
                                                );

                                                setState(() {
                                                  Navigator.of(context).pop();
                                                  findActiveParking();
                                                });
                                              } else if (state
                                                  is ParkingsError) {
                                                scaffoldMessenger.showSnackBar(
                                                  SnackBar(
                                                    duration: const Duration(
                                                        seconds: 3),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content:
                                                        Text(state.message),
                                                  ),
                                                );

                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              }
                                            });
                                            context.read<ParkingBloc>().add(
                                                DeleteParking(
                                                    parking: parkingList[
                                                        foundActiveParking!]));
                                          }
                                        },
                                        child: BlocBuilder<ParkingBloc,
                                            ParkingState>(
                                          builder: (context, state) {
                                            if (state is ParkingsLoading) {
                                              return const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            }
                                            return const Text('Avsluta');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: const Text('Avsluta'),
                              ),
                            ),
                            tileColor:
                                Theme.of(context).colorScheme.inversePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            floatingActionButton: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const ShowParkingHistory(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.inversePrimary),
              child: const Text('Visa historik'),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat);

    return content;
  }
}
