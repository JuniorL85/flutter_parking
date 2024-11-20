import 'package:flutter/material.dart';
import 'package:parking_admin/views/add_parkingplace.dart';
import 'package:parking_admin/views/delete_parkingplace.dart';
import 'package:parking_admin/views/update_parkingplace.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'ParkHere - Administrera parkeringsplatser'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
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
  ];

  var views = [
    const AddParkingplace(),
    const UpdateParkingplace(),
    const DeleteParkingplace(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
