import 'package:flutter/material.dart';
import 'package:parking_admin/providers/change_theme_provider.dart';
import 'package:parking_admin/providers/get_parking_provider.dart';
import 'package:parking_admin/views/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GetParking(),
        ),
        ChangeNotifierProvider(
          create: (context) => ChangeThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      themeMode: context.watch<ChangeThemeProvider>().currentThemeMode,
      darkTheme: ThemeData.dark(),
      home: const HomePage(title: 'ParkHere - Administrera parkeringsplatser'),
    );
  }
}
