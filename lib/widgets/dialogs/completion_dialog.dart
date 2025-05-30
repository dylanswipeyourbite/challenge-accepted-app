// lib/widgets/dialogs/completion_dialog.dart

import 'package:flutter/material.dart';

class CompletionDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onComplete;

  const CompletionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.celebration,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onComplete();
          },
          child: const Text(
            'Back to Home',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}