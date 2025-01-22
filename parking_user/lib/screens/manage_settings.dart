import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/auth_cubit.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/bloc/theme/theme_bloc.dart';
import 'package:parking_user/bloc/vehicle/vehicle_bloc.dart';

enum ThemeSelected { lightTheme, darkTheme, defaultTheme }

class ManageSettings extends StatefulWidget {
  const ManageSettings({super.key});

  @override
  State<ManageSettings> createState() => _ManageSettingsState();
}

class _ManageSettingsState extends State<ManageSettings> {
  final formKey = GlobalKey<FormState>();
  String? name;
  List<Vehicle> vehicleList = [];
  late Person person;
  StreamSubscription? personSubscription;
  StreamSubscription? vehicleSubscription;
  StreamSubscription? _updatePersonSubscription;
  StreamSubscription? _deletePersonSubscription;

  @override
  void initState() {
    super.initState();
    getVehicleListAndPerson();
  }

  @override
  void dispose() {
    personSubscription?.cancel();
    _updatePersonSubscription?.cancel();
    _deletePersonSubscription?.cancel();
    vehicleSubscription?.cancel();
    super.dispose();
  }

  getVehicleListAndPerson() async {
    if (mounted) {
      final personState = context.read<PersonBloc>().state;
      if (personState is PersonLoaded) {
        person = personState.person;

        personSubscription = context.read<PersonBloc>().stream.listen((state) {
          if (state is PersonLoaded) {
            setState(() {
              person = state.person;
            });
          }
        });
        final vehicleState = context.read<VehicleBloc>().state;
        if (vehicleState is! VehiclesLoaded) {
          context.read<VehicleBloc>().add(LoadVehiclesByPerson(person: person));
        } else {
          setState(() {
            vehicleList = vehicleState.vehicles;
          });
        }

        vehicleSubscription =
            context.read<VehicleBloc>().stream.listen((state) {
          if (state is VehiclesLoaded) {
            setState(() {
              vehicleList = state.vehicles;
            });
          }
        });
      } else {
        person = Person(name: '', socialSecurityNumber: '', email: '');
      }
    }
  }

  // getPerson() {
  //   if (mounted) {
  //     final personState = context.read<PersonBloc>().state;
  //     if (personState is PersonLoaded) {
  //       person = personState.person;
  //     } else {
  //       person = Person(name: '', socialSecurityNumber: '');
  //     }
  //     personSubscription = context.read<PersonBloc>().stream.listen((state) {
  //       if (state is PersonLoaded) {
  //         setState(() {
  //           person = state.person;
  //         });
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Text(
              'Inställningar',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Form(
                    key: formKey,
                    child: ListTile(
                      title: Text(
                        'Uppdatera namn',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(width: 120),
                        child: ElevatedButton(
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Uppdatera'),
                              content: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: TextFormField(
                                  initialValue: person.name,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Ange ett namn";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Ange namn',
                                  ),
                                  onChanged: (value) => name = value,
                                  onSaved: (value) => name = value,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Avbryt'),
                                  child: const Text('Avbryt'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();

                                      if (mounted) {
                                        final bloc = context.read<PersonBloc>();

                                        _updatePersonSubscription =
                                            bloc.stream.listen((state) {
                                          if (state is PersonLoaded) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                duration: Duration(seconds: 3),
                                                backgroundColor:
                                                    Colors.lightGreen,
                                                content: Text(
                                                    'Du har uppdaterat ditt konto'),
                                              ),
                                            );
                                            setState(() {
                                              Navigator.pop(
                                                  context, 'Uppdatera');
                                            });
                                          } else if (state is PersonsError) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration:
                                                    const Duration(seconds: 3),
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(state.message),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          }
                                        });
                                        context
                                            .read<PersonBloc>()
                                            .add(UpdatePersons(
                                                person: Person(
                                              id: person.id,
                                              name: name!,
                                              socialSecurityNumber:
                                                  person.socialSecurityNumber,
                                              email: person.email,
                                            )));
                                      }
                                    }
                                  },
                                  child: const Text('Uppdatera'),
                                ),
                              ],
                            ),
                          ),
                          child: const Text('Uppdatera'),
                        ),
                      ),
                      tileColor: Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    title: Text(
                      'Tema',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 120),
                      child: ElevatedButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return BlocBuilder<ThemeBloc, AppTheme>(
                              builder: (context, appTheme) {
                                return AlertDialog(
                                  title: const Text('Tema'),
                                  content: const Text(
                                      'Ändra till det temat du föredrar'),
                                  actions: <Widget>[
                                    RadioListTile<AppTheme>(
                                      value: AppTheme.light,
                                      groupValue: appTheme,
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<ThemeBloc>().add(
                                              SwitchThemeEvent(theme: value));
                                        }
                                      },
                                      title: const Text('Ljus'),
                                    ),
                                    RadioListTile<AppTheme>(
                                      value: AppTheme.dark,
                                      groupValue: appTheme,
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<ThemeBloc>().add(
                                              SwitchThemeEvent(theme: value));
                                        }
                                      },
                                      title: const Text('Mörk'),
                                    ),
                                    RadioListTile<AppTheme>(
                                      value: AppTheme.system,
                                      groupValue: appTheme,
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<ThemeBloc>().add(
                                              SwitchThemeEvent(theme: value));
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
                    tileColor: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    title: Text(
                      'Logga ut',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 120),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                          context.read<AuthCubit>().logout();
                        },
                        child: const Text('Logga ut'),
                      ),
                    ),
                    tileColor: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Radera konto'),
            content: const Text(
                'Är du säker på att du vill radera ditt konto? Det går inte att ångra efter att du tryckt på knappen "Radera konto".'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Avbryt'),
                child: const Text('Avbryt'),
              ),
              TextButton(
                onPressed: () async {
                  final index = vehicleList.indexWhere((vehicle) =>
                      vehicle.owner?.socialSecurityNumber ==
                      person.socialSecurityNumber);

                  if (mounted) {
                    final bloc = context.read<PersonBloc>();

                    _deletePersonSubscription = bloc.stream.listen((state) {
                      if (state is PersonsLoaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            duration: Duration(seconds: 3),
                            backgroundColor: Colors.lightGreen,
                            content: Text('Du har raderat ditt konto!'),
                          ),
                        );
                        setState(() {
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        });

                        if (index != -1) {
                          context.read<VehicleBloc>().add(DeleteVehicles(
                              vehicle: Vehicle(
                                  id: vehicleList[index].id,
                                  regNr: vehicleList[index].regNr,
                                  vehicleType: vehicleList[index].vehicleType,
                                  owner: Person(
                                    id: person.id,
                                    name: person.name,
                                    socialSecurityNumber:
                                        person.socialSecurityNumber,
                                    email: person.email,
                                  ))));
                        }
                      } else if (state is PersonsError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.redAccent,
                            content: Text(state.message),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    });
                    context
                        .read<PersonBloc>()
                        .add(DeletePersons(person: person));
                  }
                },
                child: const Text('Radera konto'),
              ),
            ],
          ),
        ),
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        child: const Text('Radera konto'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
