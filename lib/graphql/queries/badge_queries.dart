// File: lib/graphql/queries/badge_queries.dart

class BadgeQueries {
  static const String getAvailableBadges = """
    query GetAvailableBadges {
      availableBadges {
        id
        type
        name
        description
        icon
        category
        criteria {
          type
          value
        }
      }
    }
  """;

  static const String getUserBadges = """
    query GetUserBadges(\$userId: ID!) {
      userBadges(userId: \$userId) {
        badge {
          id
          type
          name
          description
          icon
          category
        }
        earnedAt
        challengeId
      }
    }
  """;
}
