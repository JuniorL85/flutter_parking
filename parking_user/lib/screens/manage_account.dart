import 'package:flutter/material.dart';
import 'package:parking_user/widgets/add_vehicle.dart';
import 'package:parking_user/widgets/home.dart';
import 'package:parking_user/widgets/personal_settings.dart';
import 'package:parking_user/widgets/start_parking.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key, this.onSetNewState});

  final void Function(int index)? onSetNewState;

  @override
  State<ManageAccount> createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  int currentPageIndex = 0;

  setPageIndex(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Välkommen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setPageIndex(index);
        },
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Hem',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_sharp),
            label: 'Starta parkering',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_filled_outlined),
            selectedIcon: Icon(Icons.directions_car_filled_sharp),
            label: 'Lägg till fordon',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_sharp),
            label: 'Inställningar',
          ),
        ],
      ),
      body: <Widget>[
        const Home(),
        const StartParking(),
        const AddVehicle(),
        const PersonalSettings(),
      ][currentPageIndex],
    );
  }
}
