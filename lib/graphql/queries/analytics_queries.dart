class AnalyticsQueries {
  static const String getChallengeAnalytics = """
    query GetChallengeAnalytics(\$challengeId: ID!) {
      challengeAnalytics(challengeId: \$challengeId) {
        overview {
          totalDays
          activeDays
          restDays
          missedDays
          totalPoints
          averagePointsPerDay
          longestStreak
          currentStreak
        }
        activityDistribution {
          type
          count
          percentage
        }
        weeklyProgress {
          week
          points
          activities
        }
        personalRecords {
          type
          value
          date
          description
        }
        patterns {
          mostActiveDay
          mostActiveTime
          preferredActivity
          averageSessionDuration
        }
      }
    }
  """;

  static const String getCalendarData = """
    query GetCalendarData(\$challengeId: ID!, \$startDate: Date!, \$endDate: Date!) {
      challengeCalendarData(
        challengeId: \$challengeId
        startDate: \$startDate
        endDate: \$endDate
      ) {
        dailyLogs {
          id
          date
          type
          activityType
          points
          notes
          media {
            id
            url
            type
          }
        }
        milestoneAchievements {
          user {
            id
            displayName
          }
          achievedAt
        }
        missedDays
      }
    }
  """;
}