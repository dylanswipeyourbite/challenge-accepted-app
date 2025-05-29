class MediaMutations {
  static const String addMediaMutation = """
    mutation AddMedia(\$input: AddMediaInput!) {
      addMedia(input: \$input) {
        id
        url
        type
        uploadedAt
        caption   
      }
    }
  """;

  static const String cheerPostMutation = """
    mutation CheerPost(\$mediaId: ID!) {
      cheerPost(mediaId: \$mediaId)
    }
  """;

  static const String uncheerPostMutation = """
    mutation UncheerPost(\$mediaId: ID!) {
      uncheerPost(mediaId: \$mediaId)
    }
  """;
}
