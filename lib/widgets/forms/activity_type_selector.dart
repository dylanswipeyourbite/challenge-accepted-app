// lib/widgets/forms/activity_type_selector.dart

import 'package:flutter/material.dart';

class ActivityTypeSelector extends StatelessWidget {
  final String selectedLogType;
  final bool canTakeRestDay;
  final ValueChanged<String> onLogTypeChanged;
  final String selectedActivityType;
  final ValueChanged<String> onActivityTypeChanged;

  const ActivityTypeSelector({
    super.key,
    required this.selectedLogType,
    required this.canTakeRestDay,
    required this.onLogTypeChanged,
    required this.selectedActivityType,
    required this.onActivityTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _LogTypeCard(
                type: 'activity',
                isSelected: selectedLogType == 'activity',
                icon: Icons.directions_run,
                label: 'I was active',
                points: '+10 points',
                baseColor: Colors.green,
                onTap: () => onLogTypeChanged('activity'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LogTypeCard(
                type: 'rest',
                isSelected: selectedLogType == 'rest',
                icon: Icons.bed,
                label: 'Rest day',
                points: canTakeRestDay ? '+5 points' : 'No more this week',
                baseColor: Colors.blue,
                isEnabled: canTakeRestDay,
                onTap: canTakeRestDay ? () => onLogTypeChanged('rest') : null,
              ),
            ),
          ],
        ),
        if (selectedLogType == 'activity') ...[
          const SizedBox(height: 24),
          const Text(
            'Activity Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ActivityTypeDropdown(
            value: selectedActivityType,
            onChanged: onActivityTypeChanged,
          ),
        ],
      ],
    );
  }
}

class _LogTypeCard extends StatelessWidget {
  final String type;
  final bool isSelected;
  final IconData icon;
  final String label;
  final String points;
  final MaterialColor baseColor;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _LogTypeCard({
    required this.type,
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.points,
    required this.baseColor,
    this.isEnabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: !isEnabled
              ? Colors.grey.shade200
              : isSelected
                  ? baseColor.withOpacity(0.1)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !isEnabled
                ? Colors.grey.shade300
                : isSelected
                    ? baseColor
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: !isEnabled
                  ? Colors.grey.shade400
                  : isSelected
                      ? baseColor
                      : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: !isEnabled
                    ? Colors.grey.shade400
                    : isSelected
                        ? baseColor.shade700
                        : Colors.grey.shade600,
              ),
            ),
            Text(
              points,
              style: TextStyle(
                fontSize: 12,
                color: !isEnabled
                    ? Colors.red
                    : type == 'activity'
                        ? Colors.green
                        : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ActivityTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  static const _activityTypes = ['running', 'cycling', 'workout', 'other'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _activityTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}