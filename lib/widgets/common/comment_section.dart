// lib/widgets/common/comment_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/models/media.dart';
import 'package:challengeaccepted/models/comment.dart';
import 'package:challengeaccepted/models/user.dart' as AppUser;
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/graphql/mutations/comments_mutations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentSection extends StatefulWidget {
  final Media media;
  final ScrollController scrollController;

  const CommentSection({
    super.key,
    required this.media,
    required this.scrollController,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  late List<Comment> _localComments;

  @override
  void initState() {
    super.initState();
    _localComments = List.from(widget.media.comments);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Create optimistic comment
    final tempComment = Comment(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      author: AppUser.User(
        id: currentUser.uid,
        firebaseUid: currentUser.uid,
        displayName: currentUser.displayName ?? 'You',
        email: currentUser.email ?? '',
        avatarUrl: currentUser.photoURL,
        createdAt: DateTime.now(),
      ),
      createdAt: DateTime.now(),
    );

    // Optimistic update
    setState(() {
      _localComments.insert(0, tempComment);
    });

    _controller.clear();

    try {
      final client = GraphQLProvider.of(context).value;
      final result = await client.mutate(
        MutationOptions(
          document: gql(CommentsMutations.addComment),
          variables: {
            'input': {
              'mediaId': widget.media.id,
              'text': text,
            }
          },
        ),
      );

      if (!result.hasException && result.data != null) {
        final commentData = result.data!['addComment'] as Map<String, dynamic>;
        final newComment = Comment.fromJson(commentData);

        // Replace temp comment with real one
        setState(() {
          final index = _localComments.indexWhere((c) => c.id == tempComment.id);
          if (index != -1) {
            _localComments[index] = newComment;
          }
        });

        // Update provider
        if (mounted) {
          context.read<UserActivityProvider>().updateMediaInteraction(
            widget.media.id,
            comments: _localComments,
          );
        }
      } else {
        // Remove optimistic comment on error
        setState(() {
          _localComments.removeWhere((c) => c.id == tempComment.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to post comment')),
          );
        }
      }
    } catch (e) {
      // Remove optimistic comment on error
      setState(() {
        _localComments.removeWhere((c) => c.id == tempComment.id);
      });
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: _buildCommentsList(),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${_localComments.length}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_localComments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to comment!',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _localComments.length,
      itemBuilder: (context, index) {
        final comment = _localComments[index];
        return _CommentTile(comment: comment);
      },
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(
                isEnabled: !_isSubmitting,
                onPressed: _submitComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: comment.author.avatarUrl != null
                ? NetworkImage(comment.author.avatarUrl!)
                : null,
            backgroundColor: Colors.grey.shade300,
            child: comment.author.avatarUrl == null
                ? const Icon(Icons.person, size: 20, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class _SendButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const _SendButton({
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isEnabled ? Theme.of(context).primaryColor : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.send,
            color: isEnabled ? Colors.white : Colors.grey.shade500,
            size: 20,
          ),
        ),
      ),
    );
  }
}