import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_user/screens/manage_account.dart';

List<String> listRegNr = <String>['GDO444'];
List<String> listAvailableParkingSpaces = <String>[
  'P1',
  'P2',
  'P3',
  'P4',
  'P5'
];

class StartParking extends StatefulWidget {
  const StartParking({super.key});

  @override
  State<StartParking> createState() => _StartParkingState();
}

class _StartParkingState extends State<StartParking> {
  String dropdownRegNr = listRegNr.first;
  String dropdownAvailableParkingSpaces = listAvailableParkingSpaces.first;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Här ska anropen för att fylla listor med Fordon (regnr), och parkeringsplatser göras
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(builder: (context, constraints) {
            return Column(
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
                      child: DropdownButtonFormField<String>(
                        value: dropdownRegNr,
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
                        onChanged: (String? value) {
                          setState(() {
                            dropdownRegNr = value!;
                          });
                        },
                        items: listRegNr
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.5,
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
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                        onChanged: (String? value) {
                          setState(() {
                            dropdownAvailableParkingSpaces = value!;
                          });
                        },
                        items: listAvailableParkingSpaces
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                      onPressed: setHomePageState,
                      child: const Text('Starta parkering'),
                    )
                  ],
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
