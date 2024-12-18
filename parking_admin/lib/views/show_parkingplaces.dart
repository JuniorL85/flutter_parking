import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/bloc/parking_spaces_bloc.dart';

class ShowParkingplaces extends StatefulWidget {
  const ShowParkingplaces({super.key});

  @override
  State<ShowParkingplaces> createState() => _ShowParkingplacesState();
}

class _ShowParkingplacesState extends State<ShowParkingplaces> {
  List<ParkingSpace> parkingSpaceList = [];
  StreamSubscription? parkingSpacesSubscription;

  @override
  void initState() {
    super.initState();
    setList();
  }

  @override
  void dispose() {
    parkingSpacesSubscription?.cancel();
    super.dispose();
  }

  setList() async {
    context.read<ParkingSpacesBloc>().add(LoadParkingSpaces());
    parkingSpacesSubscription =
        context.read<ParkingSpacesBloc>().stream.listen((state) {
      if (state is ParkingSpacesLoaded) {
        setState(() {
          parkingSpaceList = state.parkingSpaces;
        });
      }
    });
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
          BlocBuilder<ParkingSpacesBloc, ParkingSpacesState>(
            builder: (context, state) {
              if (state is ParkingSpacesInitial ||
                  state is ParkingSpacesLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ParkingSpacesLoaded) {
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
              } else if (state is ParkingSpacesError) {
                return Text('Error: ${state.message}');
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
