import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/get_parking_spaces_provider.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:parking_user/providers/get_vehicle_provider.dart';
import 'package:parking_user/screens/manage_account.dart';
import 'package:provider/provider.dart';

List<ParkingSpace> listAvailableParkingSpaces = [];

class StartParking extends StatefulWidget {
  const StartParking({super.key});

  @override
  State<StartParking> createState() => _StartParkingState();
}

class _StartParkingState extends State<StartParking> {
  final formKey = GlobalKey<FormState>();
  String? dropdownAvailableParkingSpaces;
  DateTime? _selectedDate;
  late List<Vehicle> vehicleList = [];
  var _selectedRegNr;

  @override
  void initState() {
    super.initState();
    listParkingSpaces();
    getVehicleList();
  }

  setHomePageState() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ManageAccount(
          onSetNewState: (index) => index = 0,
        ),
      ),
    );
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: lastDate,
    );

    if (pickedDate == null) return null;

    if (mounted) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child ?? Container(),
          );
        },
        initialTime: TimeOfDay.fromDateTime(now),
      );

      setState(() {
        selectedTime == null
            ? now
            : _selectedDate = DateTime(
                now.year,
                now.month,
                now.day,
                selectedTime.hour,
                selectedTime.minute,
              );
      });
    } else {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  listParkingSpaces() async {
    listAvailableParkingSpaces =
        await super.context.read<GetParkingSpaces>().getAllParkingSpaces();
    dropdownAvailableParkingSpaces =
        listAvailableParkingSpaces.first.id.toString();
  }

  getVehicleList() async {
    if (mounted) {
      Person person = super.context.read<GetPerson>().person;
      List<Vehicle> list =
          await super.context.read<GetVehicle>().getAllVehicles();
      vehicleList = list
          .where((vehicle) =>
              vehicle.owner!.socialSecurityNumber ==
              person.socialSecurityNumber)
          .toList();
      setState(() {
        _selectedRegNr = vehicleList.first.regNr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                  const SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth * 0.5,
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          value: _selectedRegNr,
                          padding: const EdgeInsets.all(10),
                          icon: const Icon(Icons.arrow_drop_down_sharp),
                          elevation: 16,
                          decoration: InputDecoration(
                            label: const Text('Registreringsnummer'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  width: 0.8,
                                )),
                          ),
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                          onChanged: (value) {
                            setState(() {
                              _selectedRegNr = value!;
                            });
                          },
                          items: [
                            for (final vehicle in vehicleList)
                              DropdownMenuItem(
                                value: vehicle.regNr,
                                child: Text(
                                  vehicle.regNr,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Inget valt datum'
                                : DateFormat('yyyy-MM-dd kk:mm')
                                    .format(_selectedDate!),
                          ),
                          IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(Icons.calendar_view_month))
                        ],
                      ),
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
                          color: Theme.of(context).colorScheme.inversePrimary),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownAvailableParkingSpaces = value!;
                        });
                      },
                      items: [
                        for (final parkingSpace in listAvailableParkingSpaces)
                          DropdownMenuItem(
                            value: parkingSpace.id.toString(),
                            child: Text(
                              '${parkingSpace.id}: ${parkingSpace.address} - ${parkingSpace.pricePerHour}kr/h',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
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
                          if (formKey.currentState!.validate()) {
                            final vehicleType = vehicleList
                                .where((vehicle) =>
                                    vehicle.regNr == _selectedRegNr)
                                .first
                                .vehicleType;

                            final parkingSpace = listAvailableParkingSpaces
                                .where((parkingSpace) =>
                                    parkingSpace.id ==
                                    int.parse(dropdownAvailableParkingSpaces!))
                                .first;

                            final person = context.read<GetPerson>().person;

                            final res = await ParkingRepository.instance
                                .addParking(Parking(
                                    vehicle: Vehicle(
                                        regNr: _selectedRegNr,
                                        vehicleType: vehicleType,
                                        owner: person),
                                    parkingSpace: ParkingSpace(
                                        id: parkingSpace.id,
                                        address: parkingSpace.address,
                                        pricePerHour:
                                            parkingSpace.pricePerHour),
                                    startTime: DateTime.now(),
                                    endTime: _selectedDate!));

                            if (res.statusCode == 200) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: Colors.lightGreen,
                                    content: Text(
                                        'Du har uppdaterat fordon med registreringsnummer $_selectedRegNr'),
                                  ),
                                );
                                Navigator.of(context).pop();
                                formKey.currentState!.reset();
                              }
                            } else {
                              if (context.mounted) {
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
                          } else {
                            if (context.mounted) {
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
                        child: const Text('Starta parkering'),
                      )
                    ],
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
