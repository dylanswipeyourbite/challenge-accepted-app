class ChallengesQueries {
  static const String getChallenge = """
    query GetChallenge(\$id: ID!) {
      challenge(id: \$id) {
        id
        title
        timeLimit
        createdBy {
          displayName
          avatarUrl
        }
        participants {
          role
          progress
          dailyStreak
          status
          isCurrentUser
          user {
            displayName
            avatarUrl
          }
        }
      }
    }
  """;


  static const String getChallenges = """
    query Challenges {
      challenges {
        id
        title
        sport
        type
        timeLimit
        wager
        status
        participants {
          isCurrentUser
          user {
            id
            displayName
            avatarUrl
          }
          role
          progress
          status
        }
      }
    }
  """;

  static const String getActiveChallenges = """
    query GetActiveChallenges {
      challenges {
        id
        title
        sport
        type
        timeLimit
        wager
        status
        createdBy {
          id
          displayName
          avatarUrl
        }
        participants {
          isCurrentUser
          user {
            id
            displayName
            avatarUrl
          }
          role
          progress
          status
          dailyStreak
          totalPoints
        }
      }
    }
  """;

  static const String pendingChallenges = """
    query PendingChallenges {
      pendingChallenges {
        id
        title
        sport
        type
        timeLimit
        wager
        createdBy {
          id
          displayName
          avatarUrl
        }
        participants {
          user {
            id
            displayName
            avatarUrl
          }
          isCurrentUser
          role
          status
        }
      }
    }
  """;

  static const String getChallengeDetails = """
    query GetChallengeDetails(\$id: ID!) {
      challenge(id: \$id) {
        id
        title
        sport
        type
        startDate
        timeLimit
        wager
        status
        challengeStreak
        lastCompleteLogDate
        createdBy {
          id
          displayName
          avatarUrl
        }
        participants {
          id
          user {
            id
            displayName
            avatarUrl
          }
          role
          progress
          status
          dailyStreak
          totalPoints
          isCurrentUser
          restDays
          weeklyRestDaysUsed
        }
        todayStatus {
          allParticipantsLogged
          participantsLoggedCount
          totalParticipants
          participantsStatus {
            participant {
              id
              user {
                id
                displayName
                avatarUrl
              }
              isCurrentUser
            }
            hasLoggedToday
            lastLogTime
          }
        }
      }
    }
  """;

  static const String getTimeline = """
    query TimelineFeed {
      challenges {
        id
        title
        participants {
          role
          isCurrentUser
          media {
            url
            type
            uploadedAt
            cheers
            comments {
              id
              author {
                displayName
                avatarUrl
              }
              text
              createdAt
            }
          }
          user {
            displayName
            avatarUrl
          }
        }
      }
    }
  """;
}
