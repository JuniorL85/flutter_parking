import 'package:flutter/material.dart';
import 'package:parking_admin/providers/change_theme_provider.dart';
import 'package:parking_admin/views/add_parkingplace.dart';
import 'package:parking_admin/views/delete_parkingplace.dart';
import 'package:parking_admin/views/monitoring.dart';
import 'package:parking_admin/views/show_parkingplaces.dart';
import 'package:parking_admin/views/update_parkingplace.dart';
import 'package:provider/provider.dart';

enum ThemeSelected { lightTheme, darkTheme, defaultTheme }

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  ThemeSelected? _themeSelected;
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

  void updateTheme(value, caseInt) {
    setState(() {
      final themeProvider =
          Provider.of<ChangeThemeProvider>(context, listen: false);
      setState(() {
        _themeSelected = value;
        themeProvider.changeThemeMode(caseInt);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        title: const Text('Tema'),
                        content: const Text('Ändra till det temat du föredrar'),
                        actions: <Widget>[
                          RadioListTile<ThemeSelected>(
                            value: ThemeSelected.lightTheme,
                            groupValue: _themeSelected,
                            onChanged: (ThemeSelected? value) {
                              updateTheme(value, 0);
                            },
                            title: const Text('Ljus'),
                          ),
                          RadioListTile<ThemeSelected>(
                            value: ThemeSelected.darkTheme,
                            groupValue: _themeSelected,
                            onChanged: (ThemeSelected? value) {
                              updateTheme(value, 1);
                            },
                            title: const Text('Mörk'),
                          ),
                          RadioListTile<ThemeSelected>(
                            value: ThemeSelected.defaultTheme,
                            groupValue: _themeSelected,
                            onChanged: (ThemeSelected? value) {
                              updateTheme(value, 2);
                            },
                            title: const Text('System default'),
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
