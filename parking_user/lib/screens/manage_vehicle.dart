import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_user/widgets/add_vehicle.dart';
import 'package:parking_user/widgets/delete_vehicle.dart';
import 'package:parking_user/widgets/show_vehicles.dart';

class ManageVehicleTitle {
  IconData titleIcon;
  String titleText;

  ManageVehicleTitle({required this.titleIcon, required this.titleText});
}

class ManageVehicle extends StatelessWidget {
  ManageVehicle({super.key, this.person});

  final Person? person;

  final List<ManageVehicleTitle> manageVehicleTitle = [
    ManageVehicleTitle(titleIcon: Icons.add, titleText: 'Lägg till fordon'),
    ManageVehicleTitle(titleIcon: Icons.delete, titleText: 'Ta bort fordon'),
    ManageVehicleTitle(titleIcon: Icons.update, titleText: 'Uppdatera fordon'),
    ManageVehicleTitle(
        titleIcon: Icons.directions_car_filled_outlined,
        titleText: 'Visa alla fordon')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  switch (index) {
                    case 0:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AddVehicle(person: person),
                        ),
                      );
                      break;
                    case 1:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => DeleteVehicle(person: person),
                        ),
                      );
                      break;
                    case 3:
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const ShowVehicles(),
                        ),
                      );
                      break;
                    default:
                  }
                },
                child: Card(
                    color: Colors.orange.shade400,
                    borderOnForeground: true,
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(manageVehicleTitle[index].titleIcon),
                          Text(manageVehicleTitle[index].titleText),
                        ],
                      ),
                    )),
              );
            }),
      ),
    ));
  }
}
