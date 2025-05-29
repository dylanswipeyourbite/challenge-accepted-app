class MediaQueries {
  static const String getMediaByChallenge = """
    query MediaByChallenge(\$challengeId: ID!) {
      mediaByChallenge(challengeId: \$challengeId) {
        id
        url
        type
        uploadedAt
        user {
          displayName
          avatarUrl
        }
        comments {
          text
          createdAt
          author {
            displayName
          }
        }
        caption
        cheers
        hasCheered
      }
    }
  """;

  static const String getTimelineMedia = """
    query GetTimelineMedia {
      timelineMedia {
        id
        url
        type
        uploadedAt
        cheers
        hasCheered
        caption
        comments {
          id
          text
          author {
            id
            displayName
            avatarUrl
          }
        }
        user {
          id
          displayName
          avatarUrl
        }
        challengeId
      }
    }
    """;
}