// File: lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
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
  
  Future<void> scheduleDailyReminders() async {
    // Morning reminder at 8 AM
    await _scheduleDaily(
      id: 1,
      title: 'Good morning, Champion! 🌅',
      body: 'Ready to crush your challenges today?',
      hour: 8,
      minute: 0,
    );
    
    // Evening reminder at 7 PM
    await _scheduleDaily(
      id: 2,
      title: 'Don\'t break your streak! 🔥',
      body: 'You still have time to log today\'s activities',
      hour: 19,
      minute: 0,
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