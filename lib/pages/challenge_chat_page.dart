// lib/pages/challenge_chat_page.dart

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/chat_queries.dart';
import 'package:challengeaccepted/graphql/mutations/chat_mutations.dart';
import 'package:challengeaccepted/graphql/subscriptions/chat_subscriptions.dart';
import 'package:challengeaccepted/models/chat_message.dart';
import 'package:challengeaccepted/widgets/chat/message_bubble.dart';
import 'package:challengeaccepted/widgets/chat/message_input.dart';
import 'package:challengeaccepted/widgets/common/loading_indicator.dart';
import 'package:challengeaccepted/widgets/common/error_message.dart';

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
  
  void _scrollToBottom() {
    // Check if the scroll controller is attached before animating
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    
    final client = GraphQLProvider.of(context).value;
    
    await client.mutate(
      MutationOptions(
        document: gql(ChatMutations.sendMessage),
        variables: {
          'input': {
            'challengeId': widget.challengeId,
            'text': text,
            'type': 'text',
          },
        },
      ),
    );
    
    // Delay scroll to ensure the new message is rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }
  
  void _handleReaction(String messageId, String emoji) async {
    final client = GraphQLProvider.of(context).value;
    
    await client.mutate(
      MutationOptions(
        document: gql(ChatMutations.addReaction),
        variables: {
          'input': {
            'messageId': messageId,
            'emoji': emoji,
          },
        },
      ),
    );
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
              'Share',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera capture
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.gif),
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
  
  void _sendCelebration() async {
    final client = GraphQLProvider.of(context).value;
    
    await client.mutate(
      MutationOptions(
        document: gql(ChatMutations.sendMessage),
        variables: {
          'input': {
            'challengeId': widget.challengeId,
            'text': '🎉 Let\'s celebrate! 🎉',
            'type': 'celebration',
          },
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show challenge info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(ChatQueries.getChatMessages),
                variables: {
                  'challengeId': widget.challengeId,
                  'limit': 50,
                },
                fetchPolicy: FetchPolicy.cacheAndNetwork,
              ),
              builder: (result, {refetch, fetchMore}) {
                if (result.isLoading && result.data == null) {
                  return const LoadingIndicator();
                }
                
                if (result.hasException) {
                  return ErrorMessage(
                    message: 'Failed to load messages',
                    error: result.exception.toString(),
                    onRetry: refetch,
                  );
                }
                
                final messagesData = result.data?['chatMessages'] ?? [];
                final messages = messagesData
                    .map((json) => ChatMessage.fromJson(json))
                    .toList()
                    .reversed
                    .toList();
                
                return Subscription(
                  options: SubscriptionOptions(
                    document: gql(ChatSubscriptions.onChatMessage),
                    variables: {'challengeId': widget.challengeId},
                  ),
                  builder: (subscriptionResult) {
                    if (subscriptionResult.hasException) {
                      print('Subscription error: ${subscriptionResult.exception}');
                    }
                    
                    if (subscriptionResult.isLoading) {
                      return _buildMessageList(messages);
                    }
                    
                    // Handle new message from subscription
                    if (subscriptionResult.data != null) {
                      final newMessage = ChatMessage.fromJson(
                        subscriptionResult.data!['chatMessageAdded'],
                      );
                      
                      // Add to messages if not already present
                      if (!messages.any((m) => m.id == newMessage.id)) {
                        messages.add(newMessage);
                        
                        // Scroll to bottom after new message
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                      }
                    }
                    
                    return _buildMessageList(messages);
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
  
  Widget _buildMessageList(List<ChatMessage> messages) {
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
                color: Colors.grey.shade600,
                fontSize: 18,
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
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previousMessage = index > 0 ? messages[index - 1] : null;
        final showDateDivider = _shouldShowDateDivider(
          previousMessage?.createdAt,
          message.createdAt,
        );
        
        return Column(
          children: [
            if (showDateDivider)
              _DateDivider(date: message.createdAt),
            MessageBubble(
              message: message,
              isCurrentUser: _isCurrentUser(message.user.id),
              onReaction: (emoji) => _handleReaction(message.id, emoji),
            ),
          ],
        );
      },
    );
  }
  
  bool _isCurrentUser(String userId) {
    // TODO: Get current user ID from auth context
    // For now, return false
    return false;
  }
  
  bool _shouldShowDateDivider(DateTime? previousDate, DateTime currentDate) {
    if (previousDate == null) return true;
    
    return previousDate.day != currentDate.day ||
           previousDate.month != currentDate.month ||
           previousDate.year != currentDate.year;
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  
  const _DateDivider({required this.date});
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.day == now.day && 
                    date.month == now.month && 
                    date.year == now.year;
    
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = date.day == yesterday.day && 
                        date.month == yesterday.month && 
                        date.year == yesterday.year;
    
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
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }
}