import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth/auth_bloc.dart';
import 'package:parking_user/bloc/notifications/notification_bloc.dart';
import 'package:parking_user/bloc/parking/parking_bloc.dart';
import 'package:parking_user/bloc/parking_space/parking_spaces_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/bloc/theme/theme_bloc.dart';
import 'package:parking_user/bloc/vehicle/vehicle_bloc.dart';
import 'package:parking_user/firebase_options.dart';
import 'package:parking_user/screens/login.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:parking_user/screens/manage_account.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationsRepository notificationsRepository =
      await NotificationsRepository.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<PersonBloc>(
            create: (context) =>
                PersonBloc(personRepository: PersonRepository.personInstance)
                  ..add(LoadPersons()),
          ),
          BlocProvider<VehicleBloc>(
            create: (context) => VehicleBloc(
                vehicleRepository: VehicleRepository.vehicleInstance)
              ..add(LoadVehicles()),
          ),
          BlocProvider<ParkingBloc>(
            create: (context) => ParkingBloc(
                parkingRepository: ParkingRepository.parkingInstance)
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
          BlocProvider<NotificationBloc>(
              create: (context) => NotificationBloc(notificationsRepository)),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
                authRepository: AuthRepository(),
                personRepository: PersonRepository.personInstance)
              ..add(AuthUserSubscriptionRequested()),
          )
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
    final authState = context.watch<AuthBloc>().state;

    getStateAndPerson(AuthState state) {
      if (state is Authenticated) {
        context.read<PersonBloc>().add(LoadPersonsById(id: state.person.id));
        return const ManageAccount();
      } else {
        return const LoginView();
      }
    }

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
        home: getStateAndPerson(authState),
        locale: const Locale('sv', 'SE'),
      );
    });
  }
}
