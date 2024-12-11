import 'package:flutter/material.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/screens/manage_parkings.dart';
import 'package:parking_user/screens/manage_settings.dart';
import 'package:parking_user/screens/manage_vehicle.dart';
import 'package:parking_user/widgets/home.dart';
import 'package:provider/provider.dart';

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
    final person = context.watch<GetPerson>().person;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Välkommen ${person.name}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Theme.of(context).colorScheme.onInverseSurface,
                  Theme.of(context).colorScheme.inversePrimary
                ]),
          ),
        ),
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
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        surfaceTintColor: Theme.of(context).colorScheme.onPrimaryFixed,
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
        ManageVehicle(),
        const ManageSettings(),
      ][currentPageIndex],
    );
  }
}
