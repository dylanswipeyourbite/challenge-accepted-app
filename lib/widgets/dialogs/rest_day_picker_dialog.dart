// lib/widgets/dialogs/rest_day_picker_dialog.dart

import 'package:flutter/material.dart';

class RestDayPickerDialog extends StatefulWidget {
  const RestDayPickerDialog({super.key});

  @override
  State<RestDayPickerDialog> createState() => _RestDayPickerDialogState();
}

class _RestDayPickerDialogState extends State<RestDayPickerDialog> {
  int selectedRestDays = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Challenge'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Rest days are essential in every challenge. Please select how many rest days you want for this challenge.',
          ),
          const SizedBox(height: 16),
          DropdownButton<int>(
            value: selectedRestDays,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedRestDays = value;
                });
              }
            },
            items: List.generate(7, (index) => index).map((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  '$value rest day${value != 1 ? 's' : ''} per week',
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _buildRestDayInfo(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(selectedRestDays),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildRestDayInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Rest days give you +5 points when used wisely',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}