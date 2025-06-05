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
          id
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
          id
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
          startDate
          challengeStreak
          lastCompleteLogDate
          createdAt
          createdBy {
            id
            displayName
            avatarUrl
          }
          participants {
            id
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
            lastLogDate
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
                isCurrentUser
                user {
                  id
                  displayName
                }
              }
              hasLoggedToday
              lastLogTime
            }
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
        startDate
        challengeStreak
        lastCompleteLogDate
        createdAt
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
        createdAt
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
          id
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