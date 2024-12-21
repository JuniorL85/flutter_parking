import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_app_cli/utils/calculate.dart';
import 'package:parking_user/bloc/parking_bloc.dart';
import 'package:parking_user/bloc/person_bloc.dart';
import 'package:parking_user/bloc/vehicle_bloc.dart';
import 'package:parking_user/widgets/datepicker_parking.dart';
import 'package:parking_user/widgets/show_parking_history.dart';
import 'package:parking_user/widgets/start_parking.dart';

//ignore: must_be_immutable
class ManageParkings extends StatefulWidget {
  ManageParkings({super.key});

  bool isActiveParking = false;

  @override
  State<ManageParkings> createState() => _ManageParkingsState();
}

class _ManageParkingsState extends State<ManageParkings> {
  List<Parking> parkingList = [];
  int? foundActiveParking;
  late Person person;
  List<Vehicle> vehicleList = [];
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);
  StreamSubscription? vehicleSubscription;
  StreamSubscription? personSubscription;
  StreamSubscription? parkingSubscription;
  StreamSubscription? _updateParkingSubscription;
  StreamSubscription? _deleteParkingSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => findActiveParking());
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

  findActiveParking() async {
    if (!mounted) return;

    final personState = context.read<PersonBloc>().state;
    if (personState is PersonLoaded) {
      person = personState.person;

      final vehicleState = context.read<VehicleBloc>().state;
      if (vehicleState is VehiclesLoaded) {
        vehicleList = vehicleState.vehicles;
      } else {
        context.read<VehicleBloc>().add(LoadVehiclesByPerson(person: person));
        await Future.delayed(const Duration(milliseconds: 100));
        vehicleList = context.read<VehicleBloc>().state is VehiclesLoaded
            ? (context.read<VehicleBloc>().state as VehiclesLoaded).vehicles
            : [];
      }

      final parkingState = context.read<ParkingBloc>().state;
      if (parkingState is ParkingsLoaded) {
        parkingList = parkingState.parkings;
      } else {
        context.read<ParkingBloc>().add(LoadActiveParkings());
        await Future.delayed(const Duration(milliseconds: 100));
        parkingList = context.read<ParkingBloc>().state is ParkingsLoaded
            ? (context.read<ParkingBloc>().state as ParkingsLoaded).parkings
            : [];
      }

      final filteredParkings = parkingList.where((activeParking) {
        final matchingVehicle = vehicleList.any((v) =>
            v.regNr.toUpperCase() ==
            activeParking.vehicle!.regNr.toUpperCase());
        return matchingVehicle;
      }).toList();

      setState(() {
        parkingList = filteredParkings;
        foundActiveParking = parkingList.isEmpty ? -1 : 0;
        widget.isActiveParking = foundActiveParking != -1;
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
    return Scaffold(
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
                              color: Theme.of(context).colorScheme.onSurface),
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
                        tileColor: Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.onSecondary),
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
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        trailing: ConstrainedBox(
                          constraints:
                              const BoxConstraints.tightFor(width: 120),
                          child: ElevatedButton(
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
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
                                            if (state is ParkingsLoaded) {
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
                                            } else if (state is ParkingsError) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  content: Text(state.message),
                                                ),
                                              );
                                              Navigator.pop(context);
                                            }
                                          });
                                          context.read<ParkingBloc>().add(UpdateParking(
                                              parking: Parking(
                                                  vehicle: Vehicle(
                                                      regNr:
                                                          parkingList[foundActiveParking!]
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
                                                      parkingList[foundActiveParking!]
                                                          .startTime,
                                                  endTime: _selectedDate.value!)));
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 3),
                                              backgroundColor: Colors.redAccent,
                                              content: Text(
                                                  'Du har inte valt korrekt datum och tid!'),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    child: const Text('Uppdatera'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('Uppdatera'),
                          ),
                        ),
                        tileColor: Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.onSecondary),
                        ),
                      ),
                      const SizedBox(height: 5),
                      ListTile(
                        title: Text(
                          'Avsluta parkering',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                        trailing: ConstrainedBox(
                          constraints:
                              const BoxConstraints.tightFor(width: 120),
                          child: ElevatedButton(
                            onPressed: () => showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
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

                                        _deleteParkingSubscription =
                                            bloc.stream.listen((state) {
                                          if (state is ParkingsLoaded) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                duration: Duration(seconds: 3),
                                                backgroundColor:
                                                    Colors.lightGreen,
                                                content: Text(
                                                    'Du har avslutat din parkering!'),
                                              ),
                                            );

                                            setState(() {
                                              Navigator.pop(context);
                                              findActiveParking();
                                            });
                                          } else if (state is ParkingsError) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration:
                                                    const Duration(seconds: 3),
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(state.message),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          }
                                        });
                                        context.read<ParkingBloc>().add(
                                            DeleteParking(
                                                parking: parkingList[
                                                    foundActiveParking!]));
                                      }
                                    },
                                    child: const Text('Avsluta'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('Avsluta'),
                          ),
                        ),
                        tileColor: Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.onSecondary),
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
              backgroundColor: Theme.of(context).colorScheme.inversePrimary),
          child: const Text('Visa historik'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
