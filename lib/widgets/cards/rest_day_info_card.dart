// lib/widgets/cards/rest_day_info_card.dart

import 'package:flutter/material.dart';

class RestDayInfoCard extends StatelessWidget {
  final int usedRestDays;
  final int allowedRestDays;

  const RestDayInfoCard({
    super.key,
    required this.usedRestDays,
    required this.allowedRestDays,
  });

  @override
  Widget build(BuildContext context) {
    final remainingRestDays = allowedRestDays - usedRestDays;
    final progress = allowedRestDays > 0 ? usedRestDays / allowedRestDays : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bed, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rest days: $usedRestDays/$allowedRestDays used this week',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (remainingRestDays > 0)
                      Text(
                        '$remainingRestDays remaining',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                remainingRestDays > 0 ? Colors.blue : Colors.orange,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}