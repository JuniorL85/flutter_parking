import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_admin/providers/get_parking_provider.dart';
import 'package:parking_app_cli/utils/calculate.dart';
import 'package:provider/provider.dart';

class Monitoring extends StatefulWidget {
  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  late Future<List<Parking>> activeList;
  List<Parking> activeParkingsList = [];
  double activeParkingSum = 0;
  late String totalSum = '';
  List<Parking> mostPopularParkings = [];
  Map<int, int> mapData = {};
  late Future<List<Parking>> pList;

  @override
  void initState() {
    activeList = context.read<GetParking>().findActiveParking();
    pList = context.read<GetParking>().getAllParkings();
    setActiveParkingsListAndTotalSum();
    setMostPopularParkingSpaces();
    super.initState();
  }

  setActiveParkingsListAndTotalSum() async {
    activeParkingsList = await activeList;
    for (var i = 0; i < activeParkingsList.length; i++) {
      activeParkingSum += calculateDuration(
          activeParkingsList[i].startTime,
          activeParkingsList[i].endTime,
          activeParkingsList[i].parkingSpace!.pricePerHour);
    }
    setState(() {
      totalSum = activeParkingSum.toStringAsFixed(2);
    });
  }

  Future<void> setMostPopularParkingSpaces() async {
    List<Parking> parkingList = await pList;

    for (var parking in parkingList) {
      final parkingSpaceId = parking.parkingSpace?.id;
      if (parkingSpaceId != null) {
        mapData[parkingSpaceId] = (mapData[parkingSpaceId] ?? 0) + 1;
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
      for (var parking in parkingList) {
        final parkingSpaceId = parking.parkingSpace?.id;
        if (parkingSpaceId != null && mostPopularIds.contains(parkingSpaceId)) {
          uniqueMostPopularParkings[parkingSpaceId] = parking;
        }
      }

      setState(() {
        mostPopularParkings = uniqueMostPopularParkings.values.toList();
      });
    }
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
                    color: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    borderOnForeground: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.summarize_outlined),
                          title: const Text('Total summa aktiva parkeringar'),
                          subtitle: Text('$totalSum kr'),
                        ),
                      ],
                    ),
                  );
                } else if (index == 1) {
                  return Card(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    borderOnForeground: true,
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
                                'Parkerad på: ${mapData[parking.parkingSpace?.id]}',
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Card(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.onSecondary),
                    ),
                    borderOnForeground: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.notifications_active_sharp),
                          title: const Text('Antal aktiva'),
                          subtitle: Text('${activeParkingsList.length} st'),
                        ),
                      ],
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
                      activeParkingsList.sort(
                          (a, b) => a.id.toString().compareTo(b.id.toString()));
                    });
                  },
                  child: const Text('Sortera på id stigande'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      activeParkingsList.sort(
                          (a, b) => b.id.toString().compareTo(a.id.toString()));
                    });
                  },
                  child: const Text('Sortera på id fallande'),
                )
              ],
            ),
          ),
          FutureBuilder<List<Parking>>(
            future: activeList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
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
                              Text('Fordon: ${activeParking.vehicle?.regNr}'),
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