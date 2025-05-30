class ChallengeSubscriptions {
  static const String challengeUpdated = """
  subscription OnChallengeUpdated {
    challengeUpdated {
      id
      title
      sport
      type
      timeLimit
      wager
      status
      participants {
        user {
          id
          displayName
          avatarUrl
        }
        isCurrentUser
        role
        progress
        status
      }
    }
  }
""";
}