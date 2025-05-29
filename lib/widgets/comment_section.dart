import 'package:challengeaccepted/graphql/mutations/comments_mutations.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CommentSection extends StatefulWidget {
  final String mediaId;
  final List comments;
  final VoidCallback? onRefetch; 

  const CommentSection({
    super.key,
    required this.mediaId,
    required this.comments,
    required this.onRefetch,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController controller = TextEditingController();
  late List commentList;

  @override
  void initState() {
    super.initState();
    commentList = List.from(widget.comments);
  }

  void addLocalComment(Map newComment) {
    setState(() {
      commentList.insert(0, newComment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(CommentsMutations.addComment),
        onCompleted: (_) async {
          controller.clear();
          await Future.delayed(const Duration(milliseconds: 300));
          widget.onRefetch?.call(); // ✅ Trigger full refresh
        },
        onError: (error) {
          print('[❌] GraphQL Error: ${error?.graphqlErrors}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error?.graphqlErrors.first.message}')),
          );
        },
      ),
      builder: (runMutation, result) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: commentList.length,
                  itemBuilder: (_, index) {
                    final comment = commentList[index];
                    final author = comment['author'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: author?['avatarUrl'] != null
                            ? NetworkImage(author['avatarUrl'])
                            : null,
                        child: author?['avatarUrl'] == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(comment['text']),
                      subtitle: Text('by ${author?['displayName'] ?? 'Anonymous'}'),
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Write a comment...'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      // Optimistic update
                      final newComment = {
                        "text": text,
                        "createdAt": DateTime.now().toIso8601String(),
                        "author": {"displayName": "You"}
                      };

                      addLocalComment(newComment);

                      runMutation({
                        "input": {
                          "mediaId": widget.mediaId,
                          "text": text,
                        }
                      });

                      // print('[💬 CommentSection] Mutation run sent.');
                    },
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
