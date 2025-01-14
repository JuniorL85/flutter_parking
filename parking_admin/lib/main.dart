import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/bloc/parking_bloc.dart';
import 'package:parking_admin/bloc/parking_spaces_bloc.dart';
import 'package:parking_admin/bloc/theme_bloc.dart';
import 'package:parking_admin/firebase_options.dart';
import 'package:parking_admin/views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ParkingBloc>(
          create: (context) => ParkingBloc()..add(LoadParkings()),
        ),
        BlocProvider<ActiveParkingBloc>(
          create: (context) => ActiveParkingBloc(
              activeParkingRepository: ParkingRepository.parkingInstance)
            ..add(LoadActiveParkings()),
        ),
        BlocProvider<ParkingSpacesBloc>(
          create: (context) => ParkingSpacesBloc(
              parkingSpaceRepository:
                  ParkingSpaceRepository.parkingSpaceInstance)
            ..add(LoadParkingSpaces()),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(InitialThemeEvent()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, AppTheme>(builder: (context, state) {
      ThemeData currentTheme;
      if (state == AppTheme.light) {
        currentTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        );
      } else if (state == AppTheme.dark) {
        currentTheme = ThemeData.dark();
      } else {
        final Brightness brightness = MediaQuery.of(context).platformBrightness;
        currentTheme = brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
                useMaterial3: true,
              );
      }

      return MaterialApp(
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        theme: currentTheme,
        home:
            const HomePage(title: 'ParkHere - Administrera parkeringsplatser'),
      );
    });
  }
}
