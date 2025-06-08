import 'package:flutter/material.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  const DatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Tanggal: '),
        TextButton(
          child: Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
          ),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
        ),
      ],
    );
  }
}
