// lib/widgets/dialogs/caption_dialog.dart

import 'package:flutter/material.dart';

class CaptionDialog extends StatefulWidget {
  final String challengeTitle;

  const CaptionDialog({
    super.key,
    required this.challengeTitle,
  });

  @override
  State<CaptionDialog> createState() => _CaptionDialogState();
}

class _CaptionDialogState extends State<CaptionDialog> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a caption'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share your progress in "${widget.challengeTitle}"',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _captionController,
            decoration: const InputDecoration(
              hintText: 'Say something...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            maxLength: 200,
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final caption = _captionController.text.trim();
            Navigator.pop(context, caption);
          },
          child: const Text('Post'),
        ),
      ],
    );
  }
}