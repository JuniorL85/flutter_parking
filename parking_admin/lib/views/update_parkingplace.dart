import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/bloc/parking_spaces_bloc.dart';

class UpdateParkingplace extends StatefulWidget {
  const UpdateParkingplace({super.key});

  @override
  State<UpdateParkingplace> createState() => _UpdateParkingplaceState();
}

class _UpdateParkingplaceState extends State<UpdateParkingplace> {
  final formKey = GlobalKey<FormState>();
  bool isId = false;
  String? idToUpdate;
  String? address;
  String? pricePerHour;
  List<ParkingSpace> parkingSpaceList = [];
  ParkingSpace? chosenParkingSpace;
  StreamSubscription? parkingSpacesSubscription;
  StreamSubscription? _blocSubscription;

  @override
  void initState() {
    super.initState();
    getParkingSpaceList();
  }

  @override
  void dispose() {
    parkingSpacesSubscription?.cancel();
    _blocSubscription?.cancel();
    super.dispose();
  }

  getParkingSpaceList() async {
    context.read<ParkingSpacesBloc>().add(LoadParkingSpaces());
    parkingSpacesSubscription =
        context.read<ParkingSpacesBloc>().stream.listen((state) {
      if (state is ParkingSpacesLoaded) {
        setState(() {
          parkingSpaceList = state.parkingSpaces;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'Uppdatera parkeringsplats',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            if (!isId)
              Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ange ett id";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text(
                          'Ange id för parkeringsplats du vill ta uppdatera',
                          style: TextStyle(fontSize: 14),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              width: 0.8,
                              color: Colors.blueGrey,
                            )),
                      ),
                      onChanged: (value) => idToUpdate = value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final index = parkingSpaceList
                            .indexWhere((i) => i.id == idToUpdate);

                        if (index != -1) {
                          chosenParkingSpace = parkingSpaceList[index];
                          setState(() {
                            formKey.currentState?.reset();
                            isId = true;
                          });
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                    'Finns ingen parkeringsplats med angivet id'),
                              ),
                            );
                            formKey.currentState?.reset();
                          }
                        }
                      }
                    },
                    child: const Text('Hämta parkeringsplats'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                        key: Key(chosenParkingSpace!.address),
                        initialValue: chosenParkingSpace!.address,
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Ange en adress";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text(
                            'Ange adress',
                            style: TextStyle(fontSize: 14),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                width: 0.8,
                                color: Colors.blueGrey,
                              )),
                        ),
                        onSaved: (value) => address = value,
                        onChanged: (value) => address = value),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      key: Key(chosenParkingSpace!.pricePerHour.toString()),
                      initialValue: chosenParkingSpace!.pricePerHour.toString(),
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Ange ett timpris";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        label: const Text(
                          'Ange timpris',
                          style: TextStyle(fontSize: 14),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              width: 0.8,
                              color: Colors.blueGrey,
                            )),
                      ),
                      onSaved: (value) => pricePerHour = value,
                      onChanged: (value) => pricePerHour = value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Uppdatera parkeringsplats'),
                        content: Text(
                            'Är du säker på att du vill uppdatera parkeringsplatsen med id: ${chosenParkingSpace!.id}?\nDet går inte att ångra efter att du tryckt på knappen "Uppdatera".'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Avbryt');
                            },
                            child: const Text('Avbryt'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();

                                if (context.mounted) {
                                  final bloc =
                                      context.read<ParkingSpacesBloc>();

                                  _blocSubscription =
                                      bloc.stream.listen((state) {
                                    if (state is ParkingSpacesLoaded) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 3),
                                          backgroundColor: Colors.lightGreen,
                                          content: Text(
                                              'Du har uppdaterat parkeringsplats med id: ${chosenParkingSpace!.id}'),
                                        ),
                                      );

                                      formKey.currentState?.reset();
                                      setState(() {
                                        isId = false;
                                        Navigator.pop(context);
                                      });
                                    } else if (state is ParkingSpacesError) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                              'Något gick fel vänligen försök igen senare'),
                                        ),
                                      );
                                    }
                                  });
                                  context
                                      .read<ParkingSpacesBloc>()
                                      .add(UpdateParkingSpace(
                                          parkingSpace: ParkingSpace(
                                        id: chosenParkingSpace!.id,
                                        creatorId:
                                            chosenParkingSpace!.creatorId,
                                        address: address!,
                                        pricePerHour: int.parse(pricePerHour!),
                                      )));
                                }
                              }
                            },
                            child: BlocBuilder<ParkingSpacesBloc,
                                ParkingSpacesState>(
                              builder: (context, state) {
                                if (state is ParkingSpacesLoading) {
                                  return const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                                return const Text('Uppdatera');
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    child: const Text('Uppdatera parkeringsplats'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
