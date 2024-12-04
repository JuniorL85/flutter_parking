import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/get_parking_provider.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/providers/get_vehicle_provider.dart';
import 'package:parking_user/widgets/start_parking.dart';
import 'package:provider/provider.dart';

class ManageParkings extends StatefulWidget {
  ManageParkings(this.findActive, {super.key});

  bool isActiveParking = false;

  final void Function() findActive;

  @override
  State<ManageParkings> createState() => _ManageParkingsState();
}

class _ManageParkingsState extends State<ManageParkings> {
  @override
  void initState() {
    super.initState();
    findActiveParking();
  }

  findActiveParking() async {
    var parkingList = await super.context.read<GetParking>().getAllParkings();

    if (mounted) {
      Person person = super.context.read<GetPerson>().person;
      List<Vehicle> list =
          await super.context.read<GetVehicle>().getAllVehicles();
      var vehicleList = list
          .where((vehicle) =>
              vehicle.owner!.socialSecurityNumber ==
              person.socialSecurityNumber)
          .toList();

      final foundActiveParking = parkingList.indexWhere(
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
                      leading: const Icon(Icons.start),
                      title: Text(
                        'Starta parkering',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      tileColor: Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      onTap: () {
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
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: Text(
                        'Uppdatera parkering',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
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
                      leading: const Icon(Icons.delete),
                      title: Text(
                        'Avsluta parkering',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      tileColor: Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      onTap: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Avsluta parkering'),
                          content: const Text(
                              'Är du säker på att du vill avsluta din parkering? Det går inte att ångra efter att du tryckt på knappen "Avsluta".'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Avbryt'),
                              child: const Text('Avbryt'),
                            ),
                            TextButton(
                              onPressed: () async {
                                var parkingList = await context
                                    .read<GetParking>()
                                    .getAllParkings();

                                if (context.mounted) {
                                  Person person =
                                      context.read<GetPerson>().person;
                                  List<Vehicle> list = await context
                                      .read<GetVehicle>()
                                      .getAllVehicles();
                                  var vehicleList = list
                                      .where((vehicle) =>
                                          vehicle.owner!.socialSecurityNumber ==
                                          person.socialSecurityNumber)
                                      .toList();

                                  final foundActiveParking =
                                      parkingList.indexWhere(
                                    (activeParking) => (vehicleList.any((v) =>
                                            v.regNr.toUpperCase() ==
                                            activeParking.vehicle!.regNr
                                                .toUpperCase()) &&
                                        activeParking.endTime
                                                .microsecondsSinceEpoch >
                                            DateTime.now()
                                                .microsecondsSinceEpoch),
                                  );

                                  final res = await ParkingRepository.instance
                                      .deleteParkings(
                                          parkingList[foundActiveParking]);

                                  if (res.statusCode == 200) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.lightGreen,
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
                                }
                              },
                              child: const Text('Avsluta'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
