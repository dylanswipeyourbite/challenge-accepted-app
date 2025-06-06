// lib/pages/challenge_chat_page.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/chat_queries.dart';
import 'package:challengeaccepted/graphql/mutations/chat_mutations.dart';
import 'package:challengeaccepted/graphql/subscriptions/chat_subscriptions.dart';
import 'package:challengeaccepted/models/chat_message.dart';
import 'package:challengeaccepted/widgets/chat/message_bubble.dart';
import 'package:challengeaccepted/widgets/chat/message_input.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChallengeChatPage extends StatefulWidget {
  final String challengeId;
  
  const ChallengeChatPage({
    super.key,
    required this.challengeId,
  });
  
  @override
  State<ChallengeChatPage> createState() => _ChallengeChatPageState();
}

class _ChallengeChatPageState extends State<ChallengeChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _sendMessage(GraphQLClient client) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    
    try {
      await client.mutate(
        MutationOptions(
          document: gql(ChatMutations.sendMessage),
          variables: {
            'input': {
              'challengeId': widget.challengeId,
              'text': text,
              'type': 'text',
            }
          },
        ),
      );
      
      // Scroll to bottom
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
  
  Future<void> _addReaction(String messageId, String emoji, GraphQLClient client) async {
    try {
      await client.mutate(
        MutationOptions(
          document: gql(ChatMutations.addReaction),
          variables: {
            'input': {
              'messageId': messageId,
              'emoji': emoji,
            }
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add reaction: $e')),
      );
    }
  }
  
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Send',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo/Video'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement photo/video sharing
              },
            ),
            ListTile(
              leading: const Icon(Icons.gif_box),
              title: const Text('GIF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement GIF picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.celebration),
              title: const Text('Celebration'),
              onTap: () {
                Navigator.pop(context);
                _sendCelebration();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _sendCelebration() {
    final client = GraphQLProvider.of(context).value;
    client.mutate(
      MutationOptions(
        document: gql(ChatMutations.sendMessage),
        variables: {
          'input': {
            'challengeId': widget.challengeId,
            'text': '🎉 Let\'s celebrate! 🎉',
            'type': 'celebration',
          }
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show chat info/participants
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list with subscription
          Expanded(
            child: Subscription(
              options: SubscriptionOptions(
                document: gql(ChatSubscriptions.onChatMessage),
                variables: {'challengeId': widget.challengeId},
              ),
              builder: (result) {
                return Query(
                  options: QueryOptions(
                    document: gql(ChatQueries.getChatMessages),
                    variables: {
                      'challengeId': widget.challengeId,
                      'limit': 50,
                    },
                    fetchPolicy: FetchPolicy.cacheAndNetwork,
                  ),
                  builder: (queryResult, {fetchMore, refetch}) {
                    if (queryResult.isLoading && queryResult.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final messages = (queryResult.data?['chatMessages'] ?? [])
                        .map<ChatMessage>((json) => ChatMessage.fromJson(json))
                        .toList();
                    
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isCurrentUser = message.user.id == currentUser?.uid;
                        
                        // Show date divider if needed
                        bool showDateDivider = false;
                        if (index == messages.length - 1 ||
                            !_isSameDay(
                              messages[index].createdAt,
                              messages[index + 1].createdAt,
                            )) {
                          showDateDivider = true;
                        }
                        
                        return Column(
                          children: [
                            if (showDateDivider)
                              _DateDivider(date: message.createdAt),
                            MessageBubble(
                              message: message,
                              isCurrentUser: isCurrentUser,
                              onReaction: (emoji) => _addReaction(
                                message.id,
                                emoji,
                                GraphQLProvider.of(context).value,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Message input
          MessageInput(
            controller: _messageController,
            onSend: () => _sendMessage(GraphQLProvider.of(context).value),
            onAttachment: _showAttachmentOptions,
          ),
        ],
      ),
    );
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  
  const _DateDivider({required this.date});
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _isSameDay(date, now);
    final isYesterday = _isSameDay(
      date,
      now.subtract(const Duration(days: 1)),
    );
    
    String dateText;
    if (isToday) {
      dateText = 'Today';
    } else if (isYesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}