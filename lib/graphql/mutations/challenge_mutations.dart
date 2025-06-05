class ChallengeMutations {
  static const String createChallenge = """
    mutation CreateChallenge(\$input: CreateChallengeInput!) {
      createChallenge(input: \$input) {
        id
        title
        description
        sport
        type
        status
        startDate
        timeLimit
        minWeeklyActivities
        minPointsToJoin
        allowedActivities
        requireDailyPhoto
        milestones {
          id
          title
          description
          type
          targetValue
          icon
        }
        participants {
          id
          user {
            id
            displayName
            avatarUrl
          }
          role
          status
          restDays
        }
      }
    }
  """;
  
  static const String acceptChallenge = """
    mutation AcceptChallenge(\$challengeId: ID!, \$restDays: Int!) {
      acceptChallenge(challengeId: \$challengeId, restDays: \$restDays) {
        id
        user {
          id
          displayName
        }
        role
        status
        restDays
        joinedAt
      }
    }
    """;

  static const String declineChallenge = """
    mutation DeclineChallenge(\$challengeId: ID!, \$reason: String) {
      declineChallenge(challengeId: \$challengeId, reason: \$reason)
    }
    """;
}