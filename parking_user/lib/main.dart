import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/bloc/parking_bloc.dart';
import 'package:parking_user/bloc/parking_spaces_bloc.dart';
import 'package:parking_user/bloc/person_bloc.dart';
import 'package:parking_user/bloc/theme_bloc.dart';
import 'package:parking_user/bloc/vehicle_bloc.dart';
import 'package:parking_user/screens/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<PersonBloc>(
            create: (context) =>
                PersonBloc(personRepository: PersonRepository.instance)
                  ..add(LoadPersons()),
          ),
          BlocProvider<VehicleBloc>(
            create: (context) =>
                VehicleBloc(vehicleRepository: VehicleRepository.instance)
                  ..add(LoadVehicles()),
          ),
          BlocProvider<ParkingBloc>(
            create: (context) => ParkingBloc()..add(LoadActiveParkings()),
          ),
          BlocProvider<ParkingSpacesBloc>(
            create: (context) => ParkingSpacesBloc(
                parkingSpaceRepository: ParkingSpaceRepository.instance)
              ..add(LoadParkingSpaces()),
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
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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
