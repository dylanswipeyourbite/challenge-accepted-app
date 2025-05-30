class UserQueries {
  static const String getUserStats = """
    query GetUserStats {
      userStats {
        currentStreak
        totalPoints
        completedChallenges
        activeChallenge {
          id
          title
          allowedRestDays
          usedRestDaysThisWeek
          hasLoggedToday
        }
      }
    }
  """;
}