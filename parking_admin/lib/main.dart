import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/bloc/parking_bloc.dart';
import 'package:parking_admin/bloc/theme_bloc.dart';
import 'package:parking_admin/views/home.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ParkingBloc>(
          create: (context) => ParkingBloc()..add(LoadParkings()),
        ),
        BlocProvider<ActiveParkingBloc>(
          create: (context) => ActiveParkingBloc()..add(LoadActiveParkings()),
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
