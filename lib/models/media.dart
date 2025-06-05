// lib/models/media.dart
import 'package:challengeaccepted/models/user.dart';
import 'package:challengeaccepted/models/comment.dart';
import 'package:challengeaccepted/models/daily_log.dart';

class Media {
  final String id;
  final String challengeId;
  final User user;
  final String url;
  final MediaType type;
  final DateTime uploadedAt;
  final List<String> cheers;
  final List<Comment> comments;
  final bool hasCheered;
  final String? caption;
  final String? dailyLogId;
  final DailyLog? dailyLog;

  const Media({
    required this.id,
    required this.challengeId,
    required this.user,
    required this.url,
    required this.type,
    required this.uploadedAt,
    required this.cheers,
    required this.comments,
    required this.hasCheered,
    this.caption,
    this.dailyLogId,
    this.dailyLog,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] as String? ?? '',
      challengeId: json['challengeId'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      url: json['url'] as String? ?? '',
      type: MediaType.fromString(json['type'] as String? ?? 'photo'),
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'] as String)
          : DateTime.now(),
      cheers: (json['cheers'] as List<dynamic>?)
          ?.map((c) => c.toString())
          .toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      hasCheered: json['hasCheered'] as bool? ?? false,
      caption: json['caption'] as String?,
      dailyLogId: json['dailyLogId'] as String?,
      dailyLog: json['dailyLog'] != null
          ? DailyLog.fromJson(json['dailyLog'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'user': user.toJson(),
      'url': url,
      'type': type.value,
      'uploadedAt': uploadedAt.toIso8601String(),
      'cheers': cheers,
      'comments': comments.map((c) => c.toJson()).toList(),
      'hasCheered': hasCheered,
      'caption': caption,
      'dailyLogId': dailyLogId,
      'dailyLog': dailyLog?.toJson(),
    };
  }

  // Computed properties
  int get cheerCount => cheers.length;
  int get commentCount => comments.length;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum MediaType {
  photo('photo'),
  video('video');

  final String value;
  const MediaType(this.value);

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MediaType.photo,
    );
  }
}