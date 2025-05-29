import 'package:challengeaccepted/widgets/comment_section.dart';
import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final String mediaId;
  final List comments;
  final VoidCallback? onRefetch; 
  
  const CommentButton({
    super.key,
    required this.mediaId,
    required this.comments,
    required this.onRefetch,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: CommentSection(
              mediaId: mediaId,
              comments: comments, onRefetch: onRefetch,
            ),
          ),
        );
      },
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
            '${comments.length} comment${comments.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
