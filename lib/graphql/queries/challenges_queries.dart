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

  static const String pendingChallenges = """
    query PendingChallenges {
      pendingChallenges {
        id
        title
          createdBy {
            id
            displayName
            avatarUrl
          }
        timeLimit
        participants {
          role
          status
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
