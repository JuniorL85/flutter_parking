import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_user/bloc/parking/parking_bloc.dart';
import 'package:parking_user/bloc/parking_space/parking_spaces_bloc.dart';
import 'package:parking_user/bloc/person/person_bloc.dart';
import 'package:parking_user/bloc/vehicle/vehicle_bloc.dart';
import 'package:parking_user/widgets/datepicker_parking.dart';

List<ParkingSpace> listAvailableParkingSpaces = [];

class StartParking extends StatefulWidget {
  const StartParking({super.key});

  @override
  State<StartParking> createState() => _StartParkingState();
}

class _StartParkingState extends State<StartParking> {
  final formKey = GlobalKey<FormState>();
  String? dropdownAvailableParkingSpaces;
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier(null);
  late List<Vehicle> vehicleList = [];
  String? _selectedRegNr;
  bool isVehicleListEmpty = false;
  bool isLoading = true;
  late Person person;
  StreamSubscription? parkingSpacesSubscription;
  StreamSubscription? vehicleSubscription;
  StreamSubscription? _blocSubscription;

  @override
  void initState() {
    super.initState();
    getVehicleListAndPerson();
    listParkingSpaces();
  }

  @override
  void dispose() {
    parkingSpacesSubscription?.cancel();
    vehicleSubscription?.cancel();
    _blocSubscription?.cancel();
    super.dispose();
  }

  listParkingSpaces() async {
    context.read<ParkingSpacesBloc>().add(LoadParkingSpaces());
    parkingSpacesSubscription =
        context.read<ParkingSpacesBloc>().stream.listen((state) {
      if (state is ParkingSpacesLoading) {
        setState(() {
          isLoading = true;
        });
      }
      if (state is ParkingSpacesLoaded) {
        setState(() {
          listAvailableParkingSpaces = state.parkingSpaces;
          dropdownAvailableParkingSpaces =
              listAvailableParkingSpaces.first.id.toString();
          isLoading = false;
        });
      }
    });
  }

  getVehicleListAndPerson() async {
    if (mounted) {
      final personState = context.read<PersonBloc>().state;
      if (personState is PersonLoaded) {
        person = personState.person;

        context.read<VehicleBloc>().add(LoadVehiclesByPerson(person: person));

        vehicleSubscription =
            context.read<VehicleBloc>().stream.listen((state) {
          if (state is VehiclesLoading) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is VehiclesLoaded) {
            setState(() {
              vehicleList = state.vehicles;

              if (vehicleList.isNotEmpty) {
                setState(() {
                  _selectedRegNr = vehicleList.first.regNr;
                });
              } else {
                setState(() {
                  isVehicleListEmpty = true;
                });
              }

              isLoading = false;
            });
          }
        });
      }
    }
  }

  setShortenedId(String id) {
    return id.substring(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: !isVehicleListEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Starta parkering',
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary),
                              ),
                              const SizedBox(height: 100),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: constraints.maxWidth * 0.5,
                                    child: DropdownButtonFormField(
                                      isExpanded: true,
                                      value: _selectedRegNr,
                                      padding: const EdgeInsets.all(10),
                                      icon: const Icon(
                                          Icons.arrow_drop_down_sharp),
                                      elevation: 16,
                                      decoration: InputDecoration(
                                        label:
                                            const Text('Registreringsnummer'),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              width: 0.8,
                                            )),
                                      ),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRegNr = value!;
                                        });
                                      },
                                      onSaved: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedRegNr = value;
                                          });
                                        }
                                      },
                                      items: [
                                        for (final vehicle in vehicleList)
                                          DropdownMenuItem(
                                            value: vehicle.regNr,
                                            child: Text(
                                              vehicle.regNr,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                      valueListenable: _selectedDate,
                                      builder: (context, value, child) {
                                        return const Text('');
                                      }),
                                  Datepicker(DateTime.now(), (value) {
                                    setState(() {
                                      _selectedDate.value = value;
                                    });
                                  })
                                ],
                              ),
                              SizedBox(
                                child: DropdownButtonFormField<String>(
                                  value: dropdownAvailableParkingSpaces,
                                  padding: const EdgeInsets.all(10),
                                  icon: const Icon(Icons.arrow_drop_down_sharp),
                                  elevation: 16,
                                  decoration: InputDecoration(
                                    label: const Text('Parkeringsområde'),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          width: 0.8,
                                        )),
                                  ),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                                  onChanged: (String? value) {
                                    setState(() {
                                      dropdownAvailableParkingSpaces = value!;
                                    });
                                  },
                                  items: [
                                    for (final parkingSpace
                                        in listAvailableParkingSpaces)
                                      DropdownMenuItem(
                                        value: parkingSpace.id,
                                        child: Text(
                                          '${setShortenedId(parkingSpace.id)}: ${parkingSpace.address} - ${parkingSpace.pricePerHour}kr/h',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Avbryt'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final vehicleType = vehicleList
                                          .where((vehicle) =>
                                              vehicle.regNr == _selectedRegNr)
                                          .first
                                          .vehicleType;

                                      final parkingSpace =
                                          listAvailableParkingSpaces
                                              .where((parkingSpace) =>
                                                  parkingSpace.id ==
                                                  dropdownAvailableParkingSpaces)
                                              .first;

                                      if (_selectedDate.value != null &&
                                          vehicleType != '') {
                                        formKey.currentState!.save();

                                        final scaffoldMessenger =
                                            ScaffoldMessenger.of(context);

                                        if (context.mounted) {
                                          final bloc =
                                              context.read<ParkingBloc>();

                                          _blocSubscription =
                                              bloc.stream.listen((state) {
                                            if (state is ActiveParkingsLoaded) {
                                              scaffoldMessenger.showSnackBar(
                                                const SnackBar(
                                                  duration:
                                                      Duration(seconds: 3),
                                                  backgroundColor:
                                                      Colors.lightGreen,
                                                  content: Text(
                                                      'Du har startat en ny parkering!'),
                                                ),
                                              );

                                              if (context.mounted) {
                                                formKey.currentState?.reset();
                                                Navigator.of(context).pop();
                                              }
                                            } else if (state is ParkingsError) {
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(
                                                      seconds: 3),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  content: Text(state.message),
                                                ),
                                              );
                                            }
                                          });
                                          context.read<ParkingBloc>().add(
                                              CreateParking(
                                                  parking: Parking(
                                                      vehicle:
                                                          Vehicle(
                                                              regNr:
                                                                  _selectedRegNr!,
                                                              vehicleType:
                                                                  vehicleType,
                                                              owner: person),
                                                      parkingSpace: ParkingSpace(
                                                          id: parkingSpace.id,
                                                          creatorId:
                                                              parkingSpace
                                                                  .creatorId,
                                                          address: parkingSpace
                                                              .address,
                                                          pricePerHour:
                                                              parkingSpace
                                                                  .pricePerHour),
                                                      startTime: DateTime.now(),
                                                      endTime: _selectedDate
                                                          .value!)));
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 3),
                                              backgroundColor: Colors.redAccent,
                                              content: Text(
                                                  'Du har inte valt korrekt datum och tid!'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child:
                                        BlocBuilder<ParkingBloc, ParkingState>(
                                      builder: (context, state) {
                                        if (state is ParkingsLoading) {
                                          return const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        }
                                        return const Text('Starta parkering');
                                      },
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Du har inget fordon att parkera'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tillbaka'),
                        )
                      ],
                    ),
                  ),
          );
    return content;
  }
}
