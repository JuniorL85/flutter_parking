import 'package:flutter/material.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class ShowParkingplaces extends StatefulWidget {
  const ShowParkingplaces({super.key});

  @override
  State<ShowParkingplaces> createState() => _ShowParkingplacesState();
}

class _ShowParkingplacesState extends State<ShowParkingplaces> {
  late Future<List<ParkingSpace>> getParkingSpaces;
  List<ParkingSpace> parkingSpaceList = [];

  @override
  void initState() {
    getParkingSpaces = ParkingSpaceRepository.instance.getAllParkingSpaces();
    setList();
    super.initState();
  }

  setList() async {
    parkingSpaceList = await getParkingSpaces;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Alla parkeringsplatser',
            style: TextStyle(fontSize: 24),
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
                      parkingSpaceList.sort((a, b) => a.pricePerHour
                          .toString()
                          .compareTo(b.pricePerHour.toString()));
                    });
                  },
                  child: const Text('Sortera på stigande pris'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      parkingSpaceList.sort((a, b) => b.pricePerHour
                          .toString()
                          .compareTo(a.pricePerHour.toString()));
                    });
                  },
                  child: const Text('Sortera på fallande pris'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      parkingSpaceList
                          .sort((a, b) => a.address.compareTo(b.address));
                    });
                  },
                  child: const Text('Sortera på adress stigande'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      parkingSpaceList
                          .sort((a, b) => b.address.compareTo(a.address));
                    });
                  },
                  child: const Text('Sortera på adress fallande'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      parkingSpaceList.sort(
                          (a, b) => a.id.toString().compareTo(b.id.toString()));
                    });
                  },
                  child: const Text('Sortera på id stigande'),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                TextButton(
                  onPressed: () {
                    setState(() {
                      parkingSpaceList.sort(
                          (a, b) => b.id.toString().compareTo(a.id.toString()));
                    });
                  },
                  child: const Text('Sortera på id fallande'),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 10),
          FutureBuilder<List<ParkingSpace>>(
            future: getParkingSpaces,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: parkingSpaceList.length,
                      itemBuilder: (context, index) {
                        var parkingPlace = parkingSpaceList[index];
                        return ListTile(
                          title: SizedBox(
                            height: 90,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Id: ${parkingPlace.id.toString()}'),
                                Text('Adress: ${parkingPlace.address}'),
                                Text(
                                    'Pris: ${parkingPlace.pricePerHour.toString()}kr/h'),
                                const Divider(thickness: 1, height: 10),
                              ],
                            ),
                          ),
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
    );
  }
}
