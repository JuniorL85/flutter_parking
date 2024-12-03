import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_user/screens/manage_parkings.dart';
import 'package:parking_user/screens/manage_settings.dart';
import 'package:parking_user/screens/manage_vehicle.dart';
import 'package:parking_user/widgets/home.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key, this.onSetNewState, this.person});

  final void Function(int index)? onSetNewState;
  final Person? person;

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
        title: Text('Välkommen ${widget.person?.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            icon: const Icon(Icons.logout_sharp),
          )
        ],
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
            label: 'Parkering',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_filled_outlined),
            selectedIcon: Icon(Icons.directions_car_filled_sharp),
            label: 'Hantera fordon',
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
        ManageParkings(),
        ManageVehicle(person: widget.person),
        ManageSettings(person: widget.person),
      ][currentPageIndex],
    );
  }
}
