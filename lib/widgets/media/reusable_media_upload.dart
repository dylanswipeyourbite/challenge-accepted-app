import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:challengeaccepted/services/media_upload_service.dart';
import 'dart:typed_data';

class ReusableMediaUploadResult {
  final String url;
  final String type;
  final String? caption;

  ReusableMediaUploadResult({
    required this.url,
    required this.type,
    this.caption,
  });
}

typedef OnMediaUploaded = void Function(ReusableMediaUploadResult result);
typedef OnUploadError = void Function(String error);

class ReusableMediaUpload extends StatefulWidget {
  final String challengeId;
  final OnMediaUploaded onMediaUploaded;
  final OnUploadError? onError;
  final bool showCaption;
  final String? hintText;
  final Color? primaryColor;
  
  const ReusableMediaUpload({
    super.key,
    required this.challengeId,
    required this.onMediaUploaded,
    this.onError,
    this.showCaption = true,
    this.hintText,
    this.primaryColor,
  });

  @override
  State<ReusableMediaUpload> createState() => _ReusableMediaUploadState();
}

class _ReusableMediaUploadState extends State<ReusableMediaUpload> {
  final ImagePicker _picker = ImagePicker();
  final MediaUploadService _uploadService = MediaUploadService();
  final TextEditingController _captionController = TextEditingController();
  
  XFile? _selectedMedia;
  bool _isUploading = false;
  String? _uploadedUrl;
  String? _uploadedType;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MediaPickerSheet(picker: _picker),
    );

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = pickedFile;
      });
      await _uploadMedia(pickedFile);
    }
  }

  Future<void> _uploadMedia(XFile file) async {
    setState(() => _isUploading = true);

    try {
      final result = await _uploadService.uploadMedia(
        file: file,
        challengeId: widget.challengeId,
      );

      if (result != null) {
        setState(() {
          _uploadedUrl = result.url;
          _uploadedType = result.type;
        });
        
        // Notify parent immediately with current caption
        _notifyParent();
      }
    } catch (e) {
      widget.onError?.call(e.toString());
      _removeMedia();
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _removeMedia() {
    setState(() {
      _selectedMedia = null;
      _uploadedUrl = null;
      _uploadedType = null;
    });
    _captionController.clear();
  }

  void _notifyParent() {
    if (_uploadedUrl != null && _uploadedType != null) {
      widget.onMediaUploaded(ReusableMediaUploadResult(
        url: _uploadedUrl!,
        type: _uploadedType!,
        caption: _captionController.text.isNotEmpty 
            ? _captionController.text 
            : null,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    
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
          _buildHeader(primaryColor),
          const SizedBox(height: 12),
          if (_selectedMedia != null)
            MediaPreview(
              media: _selectedMedia!,
              onRemove: _removeMedia,
              isUploading: _isUploading,
            )
          else
            AddMediaButton(
              onTap: _pickMedia,
              primaryColor: primaryColor,
            ),
          if (widget.showCaption) ...[
            const SizedBox(height: 12),
            CaptionField(
              controller: _captionController,
              hintText: widget.hintText,
              onChanged: (_) => _notifyParent(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Color primaryColor) {
    return Row(
      children: [
        Icon(Icons.camera_alt, color: primaryColor),
        const SizedBox(width: 8),
        const Text(
          'Add Photo/Video',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_isUploading) ...[
          const Spacer(),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}

class MediaPickerSheet extends StatelessWidget {
  final ImagePicker picker;

  const MediaPickerSheet({
    super.key,
    required this.picker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose Media',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
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
      ),
    );
  }
}

class MediaPreview extends StatelessWidget {
  final XFile media;
  final VoidCallback onRemove;
  final bool isUploading;

  const MediaPreview({
    super.key,
    required this.media,
    required this.onRemove,
    this.isUploading = false,
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
          if (isUploading)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: RemoveButton(
              onTap: onRemove,
              enabled: !isUploading,
            ),
          ),
        ],
      ),
    );
  }
}

class RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;

  const RemoveButton({
    super.key,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(enabled ? 0.7 : 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          color: Colors.white.withOpacity(enabled ? 1.0 : 0.5),
          size: 20,
        ),
      ),
    );
  }
}

class AddMediaButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color primaryColor;

  const AddMediaButton({
    super.key,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.add_a_photo),
      label: const Text('Add Photo/Video'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
      ),
    );
  }
}

class CaptionField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const CaptionField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      onChanged: onChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText ?? 'Add a caption...',
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}