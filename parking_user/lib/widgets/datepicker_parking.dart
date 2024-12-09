import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Datepicker extends StatefulWidget {
  const Datepicker(this.date, this.onSelected, {super.key});

  final DateTime date;
  final void Function(DateTime)? onSelected;

  @override
  State<Datepicker> createState() => _DatepickerState();
}

class _DatepickerState extends State<Datepicker> {
  DateTime? _selectedDate;

  void presentDatePicker() async {
    final now = widget.date;
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
        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      );

      setState(() {
        selectedTime == null
            ? now
            : _selectedDate = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
        widget.onSelected?.call(_selectedDate!);
      });
    } else {
      setState(() {
        _selectedDate = pickedDate;
        widget.onSelected?.call(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _selectedDate == null
              ? 'Inget valt datum'
              : DateFormat('yyyy-MM-dd kk:mm').format(_selectedDate!),
        ),
        IconButton(
            onPressed: presentDatePicker,
            icon: const Icon(Icons.calendar_view_month))
      ],
    );
  }
}
