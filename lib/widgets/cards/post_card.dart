// lib/widgets/cards/post_card.dart
import 'package:challengeaccepted/widgets/common/post_interaction_bar.dart';
import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/media.dart';
import 'package:challengeaccepted/models/daily_log.dart';
import 'package:challengeaccepted/models/challenge_enums.dart';
import 'package:challengeaccepted/models/user.dart' as AppUser;

class PostCard extends StatelessWidget {
  final Media media;
  final DailyLog? dailyLog;

  const PostCard({
    super.key,
    required this.media,
    this.dailyLog,
  });

  @override
  Widget build(BuildContext context) {
    final hasCaption = media.caption != null && media.caption!.trim().isNotEmpty;
    final hasActivityContext = dailyLog != null || media.dailyLog != null;
    final effectiveDailyLog = dailyLog ?? media.dailyLog;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header with activity context
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserHeader(
                  user: media.user,
                  uploadedAt: media.uploadedAt,
                  activityContext: hasActivityContext && effectiveDailyLog != null 
                      ? _buildActivityBadge(effectiveDailyLog) 
                      : null,
                ),
                
                // Activity context bar
                if (hasActivityContext && effectiveDailyLog != null) ...[
                  const SizedBox(height: 12),
                  _ActivityContextBar(dailyLog: effectiveDailyLog),
                ],
              ],
            ),
          ),

          // Caption (if available)
          if (hasCaption)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                media.caption!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ),

          if (hasCaption) const SizedBox(height: 12),

          // Media
          _MediaDisplay(
            url: media.url,
            type: media.type,
          ),

          // Interaction bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: PostInteractionBar(media: media),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBadge(DailyLog dailyLog) {
    final type = dailyLog.type;
    
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (type == LogType.activity) {
      badgeColor = Colors.green;
      badgeIcon = Icons.directions_run;
      badgeText = dailyLog.activityType?.name.toUpperCase() ?? 'ACTIVITY';
    } else {
      badgeColor = Colors.blue;
      badgeIcon = Icons.bed;
      badgeText = 'REST DAY';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  final AppUser.User user;
  final DateTime uploadedAt;
  final Widget? activityContext;

  const _UserHeader({
    required this.user,
    required this.uploadedAt,
    this.activityContext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          backgroundColor: Colors.grey.shade300,
          radius: 20,
          child: user.avatarUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTimeAgo(uploadedAt),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (activityContext != null) activityContext!,
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

class _ActivityContextBar extends StatelessWidget {
  final DailyLog dailyLog;

  const _ActivityContextBar({required this.dailyLog});

  @override
  Widget build(BuildContext context) {
    final type = dailyLog.type;
    final points = dailyLog.points;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: type == LogType.activity 
            ? Colors.green.withOpacity(0.05)
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: type == LogType.activity 
              ? Colors.green.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            type == LogType.activity ? Icons.local_fire_department : Icons.bed,
            color: type == LogType.activity ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              type == LogType.activity 
                  ? 'Logged daily activity and earned $points points! 🔥'
                  : 'Taking a well-deserved rest day and earned $points points 😴',
              style: TextStyle(
                color: type == LogType.activity 
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _PointsBadge(points: points),
        ],
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  final int points;

  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '+$points',
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MediaDisplay extends StatelessWidget {
  final String url;
  final MediaType type;

  const _MediaDisplay({
    required this.url,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(0),
        bottom: Radius.circular(0),
      ),
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 200,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: 200,
          color: Colors.grey.shade200,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('Failed to load image'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}