import 'package:flutter/material.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/parking_app_cli.dart';

class ShowParkingplaces extends StatelessWidget {
  const ShowParkingplaces({super.key});

  @override
  Widget build(BuildContext context) {
    Future<List<ParkingSpace>> getParkingSpaces =
        ParkingSpaceRepository.instance.getAllParkingSpaces();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Visa alla parkeringsplatser"),
      ),
      body: FutureBuilder<List<ParkingSpace>>(
        future: getParkingSpaces,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var parkingPlace = snapshot.data![index];
                  return ListTile(
                    title: SizedBox(
                      height: 200,
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
                });
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
