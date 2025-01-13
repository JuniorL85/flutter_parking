import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:firebase_repositories/firebase_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/bloc/parking_spaces_bloc.dart';

class AddParkingplace extends StatefulWidget {
  const AddParkingplace({super.key});

  @override
  State<AddParkingplace> createState() => _AddParkingplaceState();
}

class _AddParkingplaceState extends State<AddParkingplace> {
  final formKey = GlobalKey<FormState>();
  String? address;
  String? pricePerHour;
  StreamSubscription? _blocSubscription;

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
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
              'Lägg till parkeringsplats',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: TextFormField(
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
                onChanged: (value) => address = value,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ange ett timpris";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
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
                onChanged: (value) => pricePerHour = value,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Lägg till parkeringsplats'),
                  content: const Text(
                      'Är du säker på att du vill lägga till en parkeringsplats?\nDet går inte att ångra efter att du tryckt på knappen "Lägg till".'),
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
                          if (validateNumber(pricePerHour!)) {
                            if (context.mounted) {
                              final bloc = context.read<ParkingSpacesBloc>();

                              _blocSubscription = bloc.stream.listen((state) {
                                if (state is ParkingSpacesLoaded) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.lightGreen,
                                      content: Text(
                                          'Du har lagt till en ny parkeringsplats!'),
                                    ),
                                  );

                                  formKey.currentState?.reset();
                                  Navigator.pop(context);
                                } else if (state is ParkingSpacesError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.redAccent,
                                      content: Text(
                                          'Något gick fel vänligen försök igen senare'),
                                    ),
                                  );
                                }
                              });
                              context.read<ParkingSpacesBloc>().add(
                                  CreateParkingSpace(
                                      parkingSpace: ParkingSpace(
                                          address: address!,
                                          pricePerHour:
                                              int.parse(pricePerHour!))));
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 3),
                                  backgroundColor: Colors.redAccent,
                                  content: Text(
                                      'Du måste ange pris per timme i siffror!'),
                                ),
                              );
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                    'Något gick fel vänligen försök igen senare'),
                              ),
                            );
                          }
                        }
                      },
                      child: BlocBuilder<ParkingSpacesBloc, ParkingSpacesState>(
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
                          return const Text('Lägg till');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              child: const Text('Lägg till'),
            ),
          ],
        ),
      ),
    );
  }
}
