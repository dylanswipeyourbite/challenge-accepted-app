// lib/services/notification_service.dart - Updated with backend connection

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:graphql_flutter/graphql_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  GraphQLClient? _client;
  
  void setClient(GraphQLClient client) {
    _client = client;
  }
  
  Future<void> initialize() async {
    // Initialize timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    
    // Request permissions
    await _fcm.requestPermission();
    
    // Configure local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Setup Firebase messaging handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Schedule daily reminders
    await scheduleDailyReminders();
  }
  
  // Sync FCM token with backend
  Future<void> syncFCMToken() async {
    if (_client == null) return;
    
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      
      const updateTokenMutation = '''
        mutation UpdateFCMToken(\$token: String!) {
          updateFCMToken(token: \$token) {
            id
            fcmToken
          }
        }
      ''';
      
      await _client!.mutate(
        MutationOptions(
          document: gql(updateTokenMutation),
          variables: {'token': token},
        ),
      );
      
      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        await _client!.mutate(
          MutationOptions(
            document: gql(updateTokenMutation),
            variables: {'token': newToken},
          ),
        );
      });
    } catch (e) {
      print('Error syncing FCM token: $e');
    }
  }
  
  // Get user notifications from backend
  Future<List<AppNotification>> getUserNotifications({
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    if (_client == null) return [];
    
    const query = '''
      query GetUserNotifications(\$limit: Int, \$unreadOnly: Boolean) {
        userNotifications(limit: \$limit, unreadOnly: \$unreadOnly) {
          id
          type
          title
          body
          data
          read
          createdAt
        }
      }
    ''';
    
    try {
      final result = await _client!.query(
        QueryOptions(
          document: gql(query),
          variables: {
            'limit': limit,
            'unreadOnly': unreadOnly,
          },
        ),
      );
      
      if (result.hasException) {
        throw result.exception!;
      }
      
      final notifications = result.data?['userNotifications'] as List? ?? [];
      return notifications
          .map((n) => AppNotification.fromJson(n))
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  // Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    if (_client == null) return;
    
    const mutation = '''
      mutation MarkNotificationRead(\$notificationId: ID!) {
        markNotificationRead(notificationId: \$notificationId) {
          id
          read
        }
      }
    ''';
    
    try {
      await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {'notificationId': notificationId},
        ),
      );
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? enableDailyReminders,
    String? reminderTime,
    bool? enableSocialNotifications,
    bool? enableAchievementNotifications,
  }) async {
    if (_client == null) return;
    
    const mutation = '''
      mutation UpdateNotificationSettings(
        \$enableDailyReminders: Boolean
        \$reminderTime: String
        \$enableSocialNotifications: Boolean
        \$enableAchievementNotifications: Boolean
      ) {
        updateNotificationSettings(
          enableDailyReminders: \$enableDailyReminders
          reminderTime: \$reminderTime
          enableSocialNotifications: \$enableSocialNotifications
          enableAchievementNotifications: \$enableAchievementNotifications
        ) {
          id
          notificationSettings {
            enableDailyReminders
            reminderTime
            enableSocialNotifications
            enableAchievementNotifications
          }
        }
      }
    ''';
    
    try {
      await _client!.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            if (enableDailyReminders != null) 'enableDailyReminders': enableDailyReminders,
            if (reminderTime != null) 'reminderTime': reminderTime,
            if (enableSocialNotifications != null) 'enableSocialNotifications': enableSocialNotifications,
            if (enableAchievementNotifications != null) 'enableAchievementNotifications': enableAchievementNotifications,
          },
        ),
      );
      
      // Update local reminder schedule if daily reminders changed
      if (enableDailyReminders != null || reminderTime != null) {
        await scheduleDailyReminders();
      }
    } catch (e) {
      print('Error updating notification settings: $e');
    }
  }
  
  Future<void> scheduleDailyReminders() async {
    // Cancel existing reminders
    await _localNotifications.cancel(1);
    await _localNotifications.cancel(2);
    
    // Get user settings from backend
    final settings = await _getUserNotificationSettings();
    if (!settings.enableDailyReminders) return;
    
    // Parse reminder time (format: "HH:mm")
    final parts = settings.reminderTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    // Morning reminder
    await _scheduleDaily(
      id: 1,
      title: 'Good morning, Champion! 🌅',
      body: 'Ready to crush your challenges today?',
      hour: hour,
      minute: minute,
    );
    
    // Evening reminder (if not already logged)
    await _scheduleDaily(
      id: 2,
      title: 'Don\'t break your streak! 🔥',
      body: 'You still have time to log today\'s activities',
      hour: 19,
      minute: 0,
    );
  }
  
  Future<NotificationSettings> _getUserNotificationSettings() async {
    if (_client == null) {
      return NotificationSettings(
        enableDailyReminders: true,
        reminderTime: '08:00',
        enableSocialNotifications: true,
        enableAchievementNotifications: true,
      );
    }
    
    // For now, return default settings
    // TODO: Add user settings query to backend
    return NotificationSettings(
      enableDailyReminders: true,
      reminderTime: '08:00',
      enableSocialNotifications: true,
      enableAchievementNotifications: true,
    );
  }
  
  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily activity reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  Future<void> sendStreakWarning(int currentStreak) async {
    await _localNotifications.show(
      100,
      'Streak Alert! 🚨',
      'Your $currentStreak day streak is at risk! Log your activity now.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_alerts',
          'Streak Alerts',
          channelDescription: 'Notifications about streak status',
          importance: Importance.max,
          priority: Priority.max,
          color: Colors.red,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
  
  Future<void> sendMilestoneAchieved(String milestoneName, String challengeTitle) async {
    await _localNotifications.show(
      200,
      'Milestone Achieved! 🎯',
      'You unlocked "$milestoneName" in $challengeTitle!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Milestone and achievement notifications',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.green,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
  
  Future<void> sendFriendActivity(String friendName, String activity) async {
    await _localNotifications.show(
      300,
      '$friendName just posted! 💪',
      activity,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'social',
          'Social Updates',
          channelDescription: 'Friend activity notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to appropriate screen based on payload
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate
    }
  }
  
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Show local notification when app is in foreground
    final notification = message.notification;
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default',
            'Default',
            channelDescription: 'Default notification channel',
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}

// Background message handler - must be top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
}

// Notification model
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;
  
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    required this.createdAt,
  });
  
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      body: json['body'],
      data: json['data'],
      read: json['read'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Notification settings model
class NotificationSettings {
  final bool enableDailyReminders;
  final String reminderTime;
  final bool enableSocialNotifications;
  final bool enableAchievementNotifications;
  
  NotificationSettings({
    required this.enableDailyReminders,
    required this.reminderTime,
    required this.enableSocialNotifications,
    required this.enableAchievementNotifications,
  });
}