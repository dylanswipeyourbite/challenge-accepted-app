import 'package:challengeaccepted/widgets/buttons/comment_button.dart';
import 'package:challengeaccepted/widgets/buttons/cheer_button.dart';
import 'package:flutter/material.dart';

class PostInteractionBar extends StatelessWidget {
  final String mediaId;
  final List cheers;
  final List comments;
  final bool hasCheered; 
  final VoidCallback? onRefetch;

  const PostInteractionBar({
    super.key,
    required this.mediaId,
    required this.cheers,
    required this.comments,
    required this.hasCheered,
    required this.onRefetch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CheerButton(
          mediaId: mediaId,
          cheers: cheers, 
          hasCheered: hasCheered,
          onRefetch: onRefetch,
        ),
        CommentButton(
          mediaId: mediaId,
          comments: comments,
          onRefetch: onRefetch,
        ),
      ],
    );
  }
}
