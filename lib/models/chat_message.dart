import 'package:challengeaccepted/models/user.dart';

class ChatMessage {
  final String id;
  final String text;
  final String type;
  final User user;
  final DateTime createdAt;
  final List<MessageReaction> reactions;
  final Map<String, String>? metadata;
  
  const ChatMessage({
    required this.id,
    required this.text,
    required this.type,
    required this.user,
    required this.createdAt,
    this.reactions = const [],
    this.metadata,
  });
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((r) => MessageReaction.fromJson(r))
          .toList() ?? [],
      metadata: json['metadata'] != null
          ? Map<String, String>.from(json['metadata'])
          : null,
    );
  }
}

class MessageReaction {
  final String userId;
  final String emoji;
  
  const MessageReaction({
    required this.userId,
    required this.emoji,
  });
  
  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId'],
      emoji: json['emoji'],
    );
  }
}