import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/parking_spaces_bloc.dart';
import 'package:parking_user/bloc/theme_bloc.dart';
import 'package:parking_user/bloc/vehicle_bloc.dart';
import 'package:parking_user/providers/get_parking_provider.dart';
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
      MultiBlocProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => GetPerson(),
          ),
          ChangeNotifierProvider(
            create: (context) => GetVehicle(),
          ),
          BlocProvider<VehicleBloc>(
            create: (context) => VehicleBloc()..add(LoadVehicles()),
          ),
          BlocProvider<ParkingSpacesBloc>(
            create: (context) => ParkingSpacesBloc()..add(LoadParkingSpaces()),
          ),
          ChangeNotifierProvider(
            create: (context) => GetParking(),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc()..add(InitialThemeEvent()),
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
    return BlocBuilder<ThemeBloc, AppTheme>(builder: (context, state) {
      ThemeData currentTheme;
      if (state == AppTheme.light) {
        currentTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        );
      } else if (state == AppTheme.dark) {
        currentTheme = ThemeData.dark();
      } else {
        final Brightness brightness = MediaQuery.of(context).platformBrightness;
        currentTheme = brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
                useMaterial3: true,
              );
      }

      return MaterialApp(
        title: 'ParkHere',
        debugShowCheckedModeBanner: false,
        theme: currentTheme,
        home: const Login(),
        locale: const Locale('sv', ''),
      );
    });
  }
}
