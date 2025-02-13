import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth/auth_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/screens/manage_parkings.dart';
import 'package:parking_user/screens/manage_settings.dart';
import 'package:parking_user/screens/manage_vehicle.dart';
import 'package:parking_user/widgets/home.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

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
        person = Person(name: '', socialSecurityNumber: '', email: '');
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
    final authState = context.watch<AuthBloc>().state;

    if (authState is AuthPending || authState is AuthInitial) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Välkommen ${person.name}',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
              fontStyle: FontStyle.italic,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: <Color>[
                    Theme.of(context).colorScheme.inversePrimary,
                    Theme.of(context).colorScheme.onInverseSurface
                  ]),
            ),
          ),
          automaticallyImplyLeading: false,
          leading: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Image.asset(
                'assets/images/ph.png',
                height: 40,
                width: 40,
                opacity: const AlwaysStoppedAnimation(0.5),
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
                context.read<AuthBloc>().authRepository.logout();
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
