// lib/widgets/lists/challenge_media_grid.dart

import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/media.dart';

class ChallengeMediaGrid extends StatelessWidget {
  final List<Media> mediaList;

  const ChallengeMediaGrid({
    super.key,
    required this.mediaList,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return const Center(
        child: Text("No media uploaded yet."),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final media = mediaList[index];
        return MediaGridItem(media: media);
      },
    );
  }
}

class MediaGridItem extends StatelessWidget {
  final Media media;

  const MediaGridItem({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMediaPreview(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              media.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          if (media.type == MediaType.video)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  void _showMediaPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => MediaPreviewDialog(media: media),
    );
  }
}

class MediaPreviewDialog extends StatelessWidget {
  final Media media;

  const MediaPreviewDialog({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: media.type == MediaType.photo
                    ? Image.network(
                        media.url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          padding: const EdgeInsets.all(32),
                          child: const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            media.url,
                            fit: BoxFit.contain,
                          ),
                          const Icon(
                            Icons.play_circle_fill,
                            size: 80,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          if (media.caption != null && media.caption!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                media.caption!,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}