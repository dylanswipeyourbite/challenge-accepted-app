// File: lib/graphql/mutations/milestone_mutations.dart

class MilestoneMutations {
  static const String addMilestone = """
    mutation AddMilestone(\$challengeId: ID!, \$milestone: CreateMilestoneInput!) {
      addMilestone(challengeId: \$challengeId, milestone: \$milestone) {
        id
        title
        description
        type
        targetValue
        icon
        reward
        createdAt
      }
    }
  """;

  static const String updateMilestone = """
    mutation UpdateMilestone(
      \$challengeId: ID!
      \$milestoneId: ID!
      \$updates: CreateMilestoneInput!
    ) {
      updateMilestone(
        challengeId: \$challengeId
        milestoneId: \$milestoneId
        updates: \$updates
      ) {
        id
        title
        description
        type
        targetValue
        icon
        reward
      }
    }
  """;

  static const String deleteMilestone = """
    mutation DeleteMilestone(\$challengeId: ID!, \$milestoneId: ID!) {
      deleteMilestone(challengeId: \$challengeId, milestoneId: \$milestoneId)
    }
  """;
}