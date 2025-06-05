class AnalyticsSubscriptions {
  static const String onAnalyticsUpdated = """
    subscription OnAnalyticsUpdated(\$challengeId: ID!) {
      challengeAnalyticsUpdated(challengeId: \$challengeId) {
        overview {
          currentStreak
          totalPoints
        }
      }
    }
  """;
}