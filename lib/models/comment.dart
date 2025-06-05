// lib/models/comment.dart
import 'package:challengeaccepted/models/user.dart';

class Comment {
  final String id;
  final String text;
  final User author;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      author: User.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}