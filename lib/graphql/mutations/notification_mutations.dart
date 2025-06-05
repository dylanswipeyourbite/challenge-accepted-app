class NotificationMutations {
  static const String markNotificationRead = """
    mutation MarkNotificationRead(\$notificationId: ID!) {
      markNotificationRead(notificationId: \$notificationId) {
        id
        read
      }
    }
  """;

  static const String markAllNotificationsRead = """
    mutation MarkAllNotificationsRead {
      markAllNotificationsRead
    }
  """;

  static const String updateNotificationSettings = """
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
  """;
}
