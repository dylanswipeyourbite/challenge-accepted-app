// lib/widgets/forms/media_upload_section.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:challengeaccepted/services/media_upload_service.dart';
import 'dart:typed_data';

class MediaUploadSection extends StatefulWidget {
  final String challengeId;
  final String logType;
  final TextEditingController captionController;
  final Function(String url, String type) onMediaUploaded;
  final ValueChanged<bool> onUploadingChanged;

  const MediaUploadSection({
    super.key,
    required this.challengeId,
    required this.logType,
    required this.captionController,
    required this.onMediaUploaded,
    required this.onUploadingChanged,
  });

  @override
  State<MediaUploadSection> createState() => _MediaUploadSectionState();
}

class _MediaUploadSectionState extends State<MediaUploadSection> {
  final ImagePicker _picker = ImagePicker();
  final MediaUploadService _uploadService = MediaUploadService();
  XFile? _selectedMedia;

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => _MediaPickerSheet(picker: _picker),
    );

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = pickedFile;
      });
      await _uploadMedia(pickedFile);
    }
  }

  Future<void> _uploadMedia(XFile file) async {
    widget.onUploadingChanged(true);

    try {
      final result = await _uploadService.uploadMedia(
        file: file,
        challengeId: widget.challengeId,
      );

      if (result != null) {
        widget.onMediaUploaded(result.url, result.type);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      widget.onUploadingChanged(false);
    }
  }

  void _removeMedia() {
    setState(() {
      _selectedMedia = null;
    });
    widget.onMediaUploaded('', '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          if (_selectedMedia != null)
            _MediaPreview(
              media: _selectedMedia!,
              onRemove: _removeMedia,
            )
          else
            _AddMediaButton(onTap: _pickMedia),
          const SizedBox(height: 12),
          _CaptionField(
            controller: widget.captionController,
            logType: widget.logType,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.camera_alt, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          widget.logType == 'activity'
              ? 'Share your workout!'
              : 'Share your rest day vibes!',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MediaPickerSheet extends StatelessWidget {
  final ImagePicker picker;

  const _MediaPickerSheet({required this.picker});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Take Photo'),
          onTap: () async {
            final file = await picker.pickImage(source: ImageSource.camera);
            if (context.mounted) Navigator.pop(context, file);
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Choose from Gallery'),
          onTap: () async {
            final file = await picker.pickImage(source: ImageSource.gallery);
            if (context.mounted) Navigator.pop(context, file);
          },
        ),
        ListTile(
          leading: const Icon(Icons.videocam),
          title: const Text('Record Video'),
          onTap: () async {
            final file = await picker.pickVideo(source: ImageSource.camera);
            if (context.mounted) Navigator.pop(context, file);
          },
        ),
      ],
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final XFile media;
  final VoidCallback onRemove;

  const _MediaPreview({
    required this.media,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FutureBuilder<Uint8List>(
              future: media.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _RemoveButton(onTap: onRemove),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _AddMediaButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMediaButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_a_photo),
      label: const Text('Add Photo/Video (Optional)'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }
}

class _CaptionField extends StatelessWidget {
  final TextEditingController controller;
  final String logType;

  const _CaptionField({
    required this.controller,
    required this.logType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: logType == 'activity'
            ? 'How did your workout go? Share your thoughts...'
            : 'How are you spending your rest day?',
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}