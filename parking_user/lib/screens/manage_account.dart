import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth_cubit.dart';
import 'package:parking_user/bloc/person_bloc.dart';
import 'package:parking_user/screens/manage_parkings.dart';
import 'package:parking_user/screens/manage_settings.dart';
import 'package:parking_user/screens/manage_vehicle.dart';
import 'package:parking_user/widgets/home.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key, this.onSetNewState});

  final void Function(int index)? onSetNewState;

  @override
  State<ManageAccount> createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  int currentPageIndex = 0;
  late Person person;
  StreamSubscription? personSubscription;

  @override
  void initState() {
    super.initState();
    getPerson();
  }

  @override
  void dispose() {
    personSubscription?.cancel();
    super.dispose();
  }

  setPageIndex(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  getPerson() {
    if (mounted) {
      final personState = context.read<PersonBloc>().state;
      if (personState is PersonLoaded) {
        person = personState.person;
      } else {
        person = Person(name: '', socialSecurityNumber: '');
      }
      personSubscription = context.read<PersonBloc>().stream.listen((state) {
        if (state is PersonLoaded) {
          setState(() {
            person = state.person;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthCubit>().state;

    if (authStatus == AuthStatus.authenticating) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Välkommen ${person.name}',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
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
                context.read<AuthCubit>().logout();
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
}
