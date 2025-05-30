// lib/widgets/dialogs/decline_challenge_dialog.dart

import 'package:flutter/material.dart';

class DeclineChallengeDialog extends StatefulWidget {
  final String challengeTitle;

  const DeclineChallengeDialog({
    super.key,
    required this.challengeTitle,
  });

  @override
  State<DeclineChallengeDialog> createState() => _DeclineChallengeDialogState();
}

class _DeclineChallengeDialogState extends State<DeclineChallengeDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline Challenge'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to decline "${widget.challengeTitle}"?'),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason (optional)',
              hintText: 'Let them know why you\'re declining...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_reasonController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}