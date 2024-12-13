import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_app_cli/utils/calculate.dart';
import 'package:parking_user/providers/get_parking_provider.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/providers/get_vehicle_provider.dart';
import 'package:parking_user/widgets/datepicker_parking.dart';
import 'package:parking_user/widgets/show_parking_history.dart';
import 'package:parking_user/widgets/start_parking.dart';
import 'package:provider/provider.dart';

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
  Person? person;
  List<Vehicle> vehicleList = [];
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    findActiveParking();
  }

  findActiveParking() async {
    parkingList = await super.context.read<GetParking>().getAllParkings();

    if (mounted) {
      person = super.context.read<GetPerson>().person;
      List<Vehicle> list =
          await super.context.read<GetVehicle>().getAllVehicles();
      vehicleList = list
          .where((vehicle) =>
              vehicle.owner!.socialSecurityNumber ==
              person!.socialSecurityNumber)
          .toList();

      foundActiveParking = parkingList.indexWhere(
        (activeParking) => (vehicleList.any((v) =>
                v.regNr.toUpperCase() ==
                activeParking.vehicle!.regNr.toUpperCase()) &&
            activeParking.endTime.microsecondsSinceEpoch >
                DateTime.now().microsecondsSinceEpoch),
      );

      setState(() {
        widget.isActiveParking = foundActiveParking == -1 ? false : true;
      });
    }
  }

  calculateActiveParking() {
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
                                  .then((onValue) {
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
              if (widget.isActiveParking)
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
                                        final res = await ParkingRepository.instance.updateParkings(Parking(
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
                                            endTime: _selectedDate.value!));

                                        if (res.statusCode == 200) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                duration: Duration(seconds: 3),
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
                                          }
                                        } else {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                duration: Duration(seconds: 3),
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(
                                                    'Något gick fel vänligen försök igen senare'),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          }
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
                                      final res = await ParkingRepository
                                          .instance
                                          .deleteParkings(
                                              parkingList[foundActiveParking!]);

                                      if (res.statusCode == 200) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 3),
                                              backgroundColor:
                                                  Colors.lightGreen,
                                              content: Text(
                                                  'Du har avslutat din parkering'),
                                            ),
                                          );
                                          setState(() {
                                            Navigator.pop(context);
                                            findActiveParking();
                                          });
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 3),
                                              backgroundColor: Colors.redAccent,
                                              content: Text(
                                                  'Något gick fel vänligen försök igen senare'),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
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
