import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/bloc/theme_bloc.dart';
import 'package:parking_admin/views/add_parkingplace.dart';
import 'package:parking_admin/views/delete_parkingplace.dart';
import 'package:parking_admin/views/monitoring.dart';
import 'package:parking_admin/views/show_parkingplaces.dart';
import 'package:parking_admin/views/update_parkingplace.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  double groupAlignment = -1.0;

  var destinations = const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.add_circle_outline_sharp),
      selectedIcon: Icon(Icons.add_circle_outlined),
      label: Text('Lägg till'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.update_sharp),
      label: Text('Uppdatera'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.delete_outline_sharp),
      selectedIcon: Icon(Icons.delete_sharp),
      label: Text('Ta bort'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.local_parking_sharp),
      label: Text('Visa alla'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.monitor_outlined),
      label: Text('Övervakning'),
    ),
  ];

  var views = [
    const AddParkingplace(),
    const UpdateParkingplace(),
    const DeleteParkingplace(),
    const ShowParkingplaces(),
    const Monitoring()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: <Color>[
                  Theme.of(context).colorScheme.onInverseSurface,
                  Theme.of(context).colorScheme.inversePrimary
                ]),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return BlocBuilder<ThemeBloc, AppTheme>(
                    builder: (context, appTheme) {
                      return AlertDialog(
                        title: const Text('Tema'),
                        content: const Text('Ändra till det temat du föredrar'),
                        actions: <Widget>[
                          RadioListTile<AppTheme>(
                            value: AppTheme.light,
                            groupValue: appTheme,
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<ThemeBloc>()
                                    .add(SwitchThemeEvent(theme: value));
                              }
                            },
                            title: const Text('Ljus'),
                          ),
                          RadioListTile<AppTheme>(
                            value: AppTheme.dark,
                            groupValue: appTheme,
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<ThemeBloc>()
                                    .add(SwitchThemeEvent(theme: value));
                              }
                            },
                            title: const Text('Mörk'),
                          ),
                          RadioListTile<AppTheme>(
                            value: AppTheme.system,
                            groupValue: appTheme,
                            onChanged: (value) {
                              if (value != null) {
                                context
                                    .read<ThemeBloc>()
                                    .add(SwitchThemeEvent(theme: value));
                              }
                            },
                            title: const Text('System'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              child: const Text('Tema'),
            ),
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: groupAlignment,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: labelType,
              destinations: destinations),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: views[_selectedIndex]),
        ],
      ),
    );
  }
}
