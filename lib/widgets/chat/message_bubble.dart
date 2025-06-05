// File: lib/widgets/chat/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final Function(String) onReaction;
  
  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.onReaction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: 
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser) _buildUserInfo(),
            GestureDetector(
              onLongPress: () => _showReactionPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser 
                      ? Theme.of(context).primaryColor 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isCurrentUser 
                        ? const Radius.circular(4) 
                        : const Radius.circular(16),
                    bottomLeft: !isCurrentUser 
                        ? const Radius.circular(4) 
                        : const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.type == 'achievement' || 
                        message.type == 'milestone')
                      _buildSpecialMessage(),
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrentUser 
                            ? Colors.white70 
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (message.reactions.isNotEmpty) _buildReactions(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: message.user.avatarUrl != null
                ? NetworkImage(message.user.avatarUrl!)
                : null,
            child: message.user.avatarUrl == null
                ? Text(message.user.displayName[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            message.user.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpecialMessage() {
    IconData icon;
    Color color;
    
    switch (message.type) {
      case 'achievement':
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 'milestone':
        icon = Icons.flag;
        color = Colors.green;
        break;
      default:
        icon = Icons.celebration;
        color = Colors.purple;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            message.type.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReactions() {
    final reactionGroups = <String, int>{};
    for (final reaction in message.reactions) {
      reactionGroups[reaction.emoji] = 
          (reactionGroups[reaction.emoji] ?? 0) + 1;
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: reactionGroups.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key),
                if (entry.value > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'React to this message',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              children: ['👍', '❤️', '🔥', '💪', '😂', '🎉']
                  .map((emoji) => GestureDetector(
                        onTap: () {
                          onReaction(emoji);
                          Navigator.pop(context);
                        },
                        child: Text(emoji, style: const TextStyle(fontSize: 32)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
