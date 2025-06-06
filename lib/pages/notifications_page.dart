// lib/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:challengeaccepted/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationService = context.read<NotificationService>();
      final notifications = await notificationService.getUserNotifications();
      
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () => _handleNotificationTap(notification),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    // Mark all as read in backend
    final notificationService = context.read<NotificationService>();
    
    // Create new list with all notifications marked as read
    setState(() {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        type: n.type,
        title: n.title,
        body: n.body,
        data: n.data,
        read: true, // Mark as read
        createdAt: n.createdAt,
      )).toList();
    });
    
    // Mark all as read in backend (you might need to implement this method)
    // await notificationService.markAllNotificationsRead();
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (!notification.read) {
      final notificationService = context.read<NotificationService>();
      await notificationService.markNotificationRead(notification.id);
      
      // Update the specific notification in the list
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = AppNotification(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            read: true, // Mark as read
            createdAt: notification.createdAt,
          );
        }
      });
    }
    
    // Navigate based on notification type
    _navigateBasedOnType(notification);
  }

  void _navigateBasedOnType(AppNotification notification) {
    // TODO: Implement navigation logic based on notification type and data
    switch (notification.type) {
      case 'challenge_invite':
        // Navigate to pending challenges
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 'achievement':
      case 'milestone':
        // Navigate to badges page
        Navigator.of(context).pushNamed('/badges');
        break;
      case 'social':
        // Navigate to timeline
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      default:
        // Just close the notifications page
        break;
    }
  }
}

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _getNotificationColor(notification.type).withOpacity(0.1),
        child: Icon(
          _getNotificationIcon(notification.type),
          color: _getNotificationColor(notification.type),
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            _formatTime(notification.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      trailing: notification.read
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'achievement':
      case 'milestone':
        return Icons.emoji_events;
      case 'social':
        return Icons.people;
      case 'reminder':
        return Icons.alarm;
      case 'streak_warning':
        return Icons.warning;
      case 'challenge_invite':
        return Icons.mail;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'achievement':
      case 'milestone':
        return Colors.amber;
      case 'social':
        return Colors.blue;
      case 'reminder':
        return Colors.green;
      case 'streak_warning':
        return Colors.red;
      case 'challenge_invite':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}