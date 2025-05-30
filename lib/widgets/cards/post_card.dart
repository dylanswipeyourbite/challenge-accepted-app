import 'package:challengeaccepted/widgets/common/post_interaction_bar.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String mediaId;
  final String imageUrl;
  final String displayName;
  final String avatarUrl;
  final List cheers;
  final bool hasCheered;
  final DateTime? uploadedAt;
  final List comments;
  final VoidCallback? onRefetch;
  final String? caption;
  final Map<String, dynamic>? dailyLog; // NEW: Daily log context

  const PostCard({
    super.key,
    required this.mediaId,
    required this.imageUrl,
    required this.displayName,
    required this.avatarUrl,
    required this.cheers,
    required this.hasCheered,
    required this.comments,
    this.onRefetch,
    this.uploadedAt,
    this.caption,
    this.dailyLog, // NEW: Daily activity context
  });

  @override
  Widget build(BuildContext context) {
    final hasCaption = caption != null && caption!.trim().isNotEmpty;
    final hasActivityContext = dailyLog != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 User header with activity context
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (uploadedAt != null)
                            Text(
                              _formatTimeAgo(uploadedAt!),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Activity type badge
                    if (hasActivityContext) _buildActivityBadge(),
                  ],
                ),
                
                // Activity context bar
                if (hasActivityContext) ...[
                  const SizedBox(height: 12),
                  _buildActivityContext(),
                ],
              ],
            ),
          ),

          // 📝 Caption (if available)
          if (hasCaption)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                caption!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ),

          if (hasCaption) const SizedBox(height: 12),

          // 📸 Media
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(0),
              bottom: Radius.circular(0),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
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
          ),

          // 🚀 Interaction bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: PostInteractionBar(
              mediaId: mediaId,
              cheers: cheers,
              comments: comments,
              hasCheered: hasCheered,
              onRefetch: onRefetch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBadge() {
    if (dailyLog == null) return const SizedBox.shrink();

    final type = dailyLog!['type'] as String?;
    // final points = dailyLog!['points'] as int? ?? 0;
    
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (type == 'activity') {
      badgeColor = Colors.green;
      badgeIcon = Icons.directions_run;
      final activityType = dailyLog!['activityType'] as String?;
      badgeText = activityType?.toUpperCase() ?? 'ACTIVITY';
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

  Widget _buildActivityContext() {
    if (dailyLog == null) return const SizedBox.shrink();

    final type = dailyLog!['type'] as String;
    final points = dailyLog!['points'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: type == 'activity' 
            ? Colors.green.withOpacity(0.05)
            : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: type == 'activity' 
              ? Colors.green.withOpacity(0.2)
              : Colors.blue.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            type == 'activity' ? Icons.local_fire_department : Icons.bed,
            color: type == 'activity' ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              type == 'activity' 
                  ? 'Logged daily activity and earned $points points! 🔥'
                  : 'Taking a well-deserved rest day and earned $points points 😴',
              style: TextStyle(
                color: type == 'activity' 
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
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
          ),
        ],
      ),
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