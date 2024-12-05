import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parking_user/providers/get_parking_provider.dart';
import 'package:parking_user/providers/get_parking_spaces_provider.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/providers/get_vehicle_provider.dart';
import 'package:parking_user/screens/login.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => GetPerson(),
          ),
          ChangeNotifierProvider(
            create: (context) => GetVehicle(),
          ),
          ChangeNotifierProvider(
            create: (context) => GetParkingSpaces(),
          ),
          ChangeNotifierProvider(
            create: (context) => GetParking(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkHere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      locale: const Locale('sv', ''),
      home: const Login(),
    );
  }
}
