import 'package:flutter/material.dart';
import 'package:parking_user/widgets/add_vehicle.dart';
import 'package:parking_user/widgets/delete_vehicle.dart';
import 'package:parking_user/widgets/show_vehicles.dart';
import 'package:parking_user/widgets/update_vehicle.dart';

class ManageVehicleTitle {
  IconData titleIcon;
  String titleText;

  ManageVehicleTitle({required this.titleIcon, required this.titleText});
}

class ManageVehicle extends StatelessWidget {
  ManageVehicle({super.key});

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
        body: Column(
      children: [
        const SizedBox(height: 50),
        Text(
          'Hantera fordon',
          style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.inversePrimary),
        ),
        const SizedBox(height: 50),
        SizedBox(
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
                              builder: (ctx) => const AddVehicle(),
                            ),
                          );
                          break;
                        case 1:
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const DeleteVehicle(),
                            ),
                          );
                          break;
                        case 2:
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const UpdateVehicle(),
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
                        color: Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.onSecondary),
                        ),
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
        ),
      ],
    ));
  }
}
