import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:challengeaccepted/models/chat_message.dart';
import 'package:challengeaccepted/widgets/chat/message_bubble.dart';
import 'package:challengeaccepted/widgets/chat/message_input.dart';

class ChallengeChatPage extends StatefulWidget {
  final String challengeId;
  final String challengeTitle;
  
  const ChallengeChatPage({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
  });
  
  @override
  State<ChallengeChatPage> createState() => _ChallengeChatPageState();
}

class _ChallengeChatPageState extends State<ChallengeChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  
  static const String getChatMessagesQuery = """
    query GetChatMessages(\$challengeId: ID!, \$limit: Int, \$before: String) {
      chatMessages(challengeId: \$challengeId, limit: \$limit, before: \$before) {
        id
        text
        type
        user {
          id
          displayName
          avatarUrl
        }
        createdAt
        reactions {
          userId
          emoji
        }
        metadata
      }
    }
  """;
  
  static const String sendMessageMutation = """
    mutation SendChatMessage(\$input: SendMessageInput!) {
      sendChatMessage(input: \$input) {
        id
        text
        type
        user {
          id
          displayName
          avatarUrl
        }
        createdAt
      }
    }
  """;
  
  static const String chatMessageSubscription = """
    subscription OnChatMessage(\$challengeId: ID!) {
      chatMessageAdded(challengeId: \$challengeId) {
        id
        text
        type
        user {
          id
          displayName
          avatarUrl
        }
        createdAt
        metadata
      }
    }
  """;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.challengeTitle),
            const Text(
              'Challenge Chat',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showChatInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(getChatMessagesQuery),
                variables: {
                  'challengeId': widget.challengeId,
                  'limit': 50,
                },
                fetchPolicy: FetchPolicy.cacheAndNetwork,
              ),
              builder: (result, {refetch, fetchMore}) {
                if (result.isLoading && result.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final messages = _parseMessages(result.data?['chatMessages'] ?? []);
                
                return Subscription(
                  options: SubscriptionOptions(
                    document: gql(chatMessageSubscription),
                    variables: {'challengeId': widget.challengeId},
                  ),
                  builder: (subscriptionResult) {
                    // Handle new messages from subscription
                    if (subscriptionResult.data != null) {
                      final newMessage = ChatMessage.fromJson(
                        subscriptionResult.data!['chatMessageAdded'],
                      );
                      
                      // Add to messages list if not already present
                      if (!messages.any((m) => m.id == newMessage.id)) {
                        messages.insert(0, newMessage);
                      }
                    }
                    
                    if (messages.isEmpty) {
                      return _EmptyChatState();
                    }
                    
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final previousMessage = index < messages.length - 1
                            ? messages[index + 1]
                            : null;
                        
                        final showDate = _shouldShowDate(
                          message.createdAt,
                          previousMessage?.createdAt,
                        );
                        
                        return Column(
                          children: [
                            if (showDate)
                              _DateDivider(date: message.createdAt),
                            MessageBubble(
                              message: message,
                              isCurrentUser: message.user.id == 
                                  FirebaseAuth.instance.currentUser?.uid,
                              onReaction: (emoji) => _addReaction(message.id, emoji),
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
          MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onAttachment: _showAttachmentOptions,
          ),
        ],
      ),
    );
  }
  
  List<ChatMessage> _parseMessages(List<dynamic> data) {
    return data.map((json) => ChatMessage.fromJson(json)).toList();
  }
  
  bool _shouldShowDate(DateTime current, DateTime? previous) {
    if (previous == null) return true;
    
    return current.year != previous.year ||
           current.month != previous.month ||
           current.day != previous.day;
  }
  
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    
    final client = GraphQLProvider.of(context).value;
    
    await client.mutate(
      MutationOptions(
        document: gql(sendMessageMutation),
        variables: {
          'input': {
            'challengeId': widget.challengeId,
            'text': text,
            'type': 'text',
          }
        },
      ),
    );
  }
  
  void _addReaction(String messageId, String emoji) {
    // Implementation for adding reactions
  }
  
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _AttachmentOptions(
        onGif: _sendGif,
        onPhoto: _sendPhoto,
        onCelebration: _sendCelebration,
      ),
    );
  }
  
  void _sendGif() {
    // Implementation for GIF picker
  }
  
  void _sendPhoto() {
    // Implementation for photo picker
  }
  
  void _sendCelebration() {
    // Send a celebration message
    _sendSystemMessage('🎉 Let\'s celebrate our progress! 🎉', 'celebration');
  }
  
  Future<void> _sendSystemMessage(String text, String type) async {
    final client = GraphQLProvider.of(context).value;
    
    await client.mutate(
      MutationOptions(
        document: gql(sendMessageMutation),
        variables: {
          'input': {
            'challengeId': widget.challengeId,
            'text': text,
            'type': type,
          }
        },
      ),
    );
  }
  
  void _showChatInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ChatInfoSheet(challengeId: widget.challengeId),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            'Be the first to send a message!',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  
  const _DateDivider({required this.date});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
// Missing attachment options widget
class _AttachmentOptions extends StatelessWidget {
  final VoidCallback onGif;
  final VoidCallback onPhoto;
  final VoidCallback onCelebration;
  
  const _AttachmentOptions({
    required this.onGif,
    required this.onPhoto,
    required this.onCelebration,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachmentOption(
                icon: Icons.photo,
                label: 'Photo',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  onPhoto();
                },
              ),
              _AttachmentOption(
                icon: Icons.gif_box,
                label: 'GIF',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  onGif();
                },
              ),
              _AttachmentOption(
                icon: Icons.celebration,
                label: 'Celebrate',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  onCelebration();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

// Chat info sheet
class _ChatInfoSheet extends StatelessWidget {
  final String challengeId;
  
  const _ChatInfoSheet({required this.challengeId});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chat Guidelines',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.support,
            text: 'Support and encourage your teammates',
          ),
          _InfoRow(
            icon: Icons.celebration,
            text: 'Celebrate achievements together',
          ),
          _InfoRow(
            icon: Icons.tips_and_updates,
            text: 'Share tips and motivation',
          ),
          _InfoRow(
            icon: Icons.photo_camera,
            text: 'Share progress photos',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it!'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _InfoRow({
    required this.icon,
    required this.text,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}