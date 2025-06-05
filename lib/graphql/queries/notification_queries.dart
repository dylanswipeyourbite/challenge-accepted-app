class NotificationQueries {
  static const String getUserNotifications = """
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
  """;
}