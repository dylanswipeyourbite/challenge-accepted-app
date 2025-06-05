// File: lib/graphql/subscriptions/milestone_subscriptions.dart

class MilestoneSubscriptions {
  static const String onMilestoneAchieved = """
    subscription OnMilestoneAchieved(\$challengeId: ID!) {
      milestoneAchieved(challengeId: \$challengeId) {
        user {
          id
          displayName
          avatarUrl
        }
        achievedAt
      }
    }
  """;
}