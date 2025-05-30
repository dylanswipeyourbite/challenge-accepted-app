// lib/services/media_upload_service.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MediaUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<MediaUploadResult?> uploadMedia({
    required XFile file,
    required String challengeId,
  }) async {
    try {
      final fileBytes = await file.readAsBytes();
      final fileName = file.name;
      final fileExtension = fileName.split('.').last.toLowerCase();

      final storageRef = _storage
          .ref()
          .child('challenges/$challengeId/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = storageRef.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getContentType(fileExtension),
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return MediaUploadResult(
        url: downloadUrl,
        type: _getMediaType(fileExtension),
      );
    } catch (e) {
      throw MediaUploadException('Failed to upload media: $e');
    }
  }

  String _getContentType(String extension) {
    if (['mp4', 'mov'].contains(extension)) {
      return 'video/mp4';
    }
    return 'image/jpeg';
  }

  String _getMediaType(String extension) {
    if (['mp4', 'mov'].contains(extension)) {
      return 'video';
    }
    return 'photo';
  }
}

class MediaUploadResult {
  final String url;
  final String type;

  MediaUploadResult({
    required this.url,
    required this.type,
  });
}

class MediaUploadException implements Exception {
  final String message;

  MediaUploadException(this.message);

  @override
  String toString() => message;
}