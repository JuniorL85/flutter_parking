import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_admin/providers/get_parking_provider.dart';
import 'package:parking_app_cli/utils/calculate.dart';
import 'package:provider/provider.dart';

class ShowActiveParkings extends StatefulWidget {
  const ShowActiveParkings({super.key});

  @override
  State<ShowActiveParkings> createState() => _ShowActiveParkingsState();
}

class _ShowActiveParkingsState extends State<ShowActiveParkings> {
  late Future<List<Parking>> list;
  List<Parking> activeParkingsList = [];
  double activeParkingSum = 0;
  String totalSum = '';

  @override
  void initState() {
    list = context.read<GetParking>().findActiveParking();
    setActiveParkingsListAndTotalSum();
    super.initState();
  }

  setActiveParkingsListAndTotalSum() async {
    activeParkingsList = await list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktiva parkeringar'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Total summa aktiva parkeringar: $totalSum kr',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Text(
                  'Antal aktiva: ${activeParkingsList.length} st',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                  ),
                )
              ],
            ),
          ),
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
            future: list,
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
