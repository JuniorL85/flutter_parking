import 'dart:async';

import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_admin/bloc/parking_spaces_bloc.dart';

class DeleteParkingplace extends StatefulWidget {
  const DeleteParkingplace({super.key});

  @override
  State<DeleteParkingplace> createState() => _DeleteParkingplaceState();
}

class _DeleteParkingplaceState extends State<DeleteParkingplace> {
  final formKey = GlobalKey<FormState>();
  String? idToDelete;
  List<ParkingSpace> parkingSpaceList = [];
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
              'Ta bort parkeringsplats',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
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
                    'Ange id för parkeringsplats du vill ta bort',
                    style: TextStyle(fontSize: 14),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        width: 0.8,
                        color: Colors.blueGrey,
                      )),
                ),
                onChanged: (value) => idToDelete = value,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Ta bort parkeringsplats'),
                  content: Text(
                      'Är du säker på att du vill radera parkeringsplats med id: $idToDelete?\nDet går inte att ångra efter att du tryckt på knappen "Ta bort".'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Avbryt'),
                      child: const Text('Avbryt'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final index = parkingSpaceList
                              .indexWhere((i) => i.id == idToDelete);

                          if (index != -1) {
                            if (context.mounted) {
                              final bloc = context.read<ParkingSpacesBloc>();

                              _blocSubscription = bloc.stream.listen((state) {
                                if (state is ParkingSpacesLoaded) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.lightGreen,
                                      content: Text(
                                          'Du har raderat parkeringsplats med id: $idToDelete'),
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
                                  DeleteParkingSpace(
                                      parkingSpace: parkingSpaceList[index]));
                            }
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
                            }
                            formKey.currentState?.reset();
                            Navigator.pop(context);
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
                            Navigator.pop(context);
                          }
                          return;
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
                          return const Text('Ta bort');
                        },
                      ),
                    )
                  ],
                ),
              ),
              child: const Text('Ta bort'),
            ),
          ],
        ),
      ),
    );
  }
}
