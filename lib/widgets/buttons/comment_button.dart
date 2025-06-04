// lib/widgets/buttons/provider_aware_comment_button.dart
import 'package:challengeaccepted/widgets/common/comment_section.dart';
import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/media.dart';

class CommentButton extends StatelessWidget {
  final Media media;

  const CommentButton({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCommentSection(context),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: 1.0),
            duration: const Duration(milliseconds: 200),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: const Icon(Icons.comment, color: Colors.grey),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            '${media.commentCount} comment${media.commentCount == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showCommentSection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => CommentSection(
          media: media,
          scrollController: scrollController,
        ),
      ),
    );
  }
}