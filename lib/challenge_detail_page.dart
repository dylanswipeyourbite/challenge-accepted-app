import 'package:challengeaccepted/graphql/mutations/media_mutations.dart';
import 'package:challengeaccepted/graphql/queries/challenges_queries.dart';
import 'package:challengeaccepted/graphql/queries/media_queries.dart';
import 'package:challengeaccepted/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ChallengeDetailPage extends StatefulWidget {
  final Map<String, dynamic> challenge;

  const ChallengeDetailPage({required this.challenge, super.key});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  final ImagePicker _picker = ImagePicker();

  final TextEditingController captionController = TextEditingController();

  Future<void> _pickAndUploadMedia(RunMutation runMutation) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Prompt user for a caption
    final caption = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a caption'),
          content: TextField(
            controller: captionController,
            decoration: const InputDecoration(hintText: 'Say something...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, captionController.text.trim()),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );

    if (caption == null) return;

    final fileBytes = await pickedFile.readAsBytes();
    final fileName = pickedFile.name;
    final fileExtension = fileName.split('.').last;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('challenges/${widget.challenge['id']}/$fileName');

    final uploadTask = storageRef.putData(fileBytes, SettableMetadata(
      contentType: fileExtension == 'mp4' ? 'video/mp4' : 'image/jpeg',
    ));

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    final isVideo = fileExtension.toLowerCase() == 'mp4' || fileExtension.toLowerCase() == 'mov';

    runMutation({
      "input": {
        "challengeId": widget.challenge['id'],
        "url": downloadUrl,
        "type": isVideo ? "video" : "photo",
        "caption": caption,  // ✅ Include it here
      }
    });

    captionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(MediaQueries.getMediaByChallenge),
        variables: {'challengeId': widget.challenge['id']},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading && result.data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (result.hasException) {
          return Scaffold(body: Center(child: Text('Error: ${result.exception.toString()}')));
        }

        final mediaList = result.data!['mediaByChallenge'];

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.challenge['title']),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.photo), text: "Media"),
                  Tab(icon: Icon(Icons.local_fire_department), text: "Streaks"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: RefreshIndicator(
                    onRefresh: () async => await refetch?.call(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          ...mediaList.map((entry) {
                            final user = entry['user'];
                            print('before passing through:');
                            print(entry['caption']);
                            return PostCard(
                              mediaId: entry['id'],
                              imageUrl: entry['url'],
                              displayName: user['displayName'],
                              avatarUrl: user['avatarUrl'],
                              hasCheered: entry['hasCheered'] ?? false,
                              cheers: entry['cheers'] ?? [],
                              uploadedAt: DateTime.tryParse(entry['uploadedAt'] ?? ''),
                              comments: entry['comments'] ?? [],
                              onRefetch: refetch,
                              caption: entry['caption'],
                            );
                          }),
                          const SizedBox(height: 20),
                          Mutation(
                            options: MutationOptions(
                              document: gql(MediaMutations.addMediaMutation),
                              onCompleted: (_) => refetch?.call(),
                              onError: (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('❌ Upload failed: ${error?.graphqlErrors.first.message}')),
                                );
                              },
                            ),
                            builder: (runMutation, result) {
                              return ElevatedButton.icon(
                                onPressed: () => _pickAndUploadMedia(runMutation),
                                icon: const Icon(Icons.add_a_photo),
                                label: const Text('Upload Photo/Video'),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Query(
                  options: QueryOptions(
                    document: gql(ChallengesQueries.getChallenge),
                    variables: {'id': widget.challenge['id']},
                    fetchPolicy: FetchPolicy.cacheAndNetwork,
                  ),
                  builder: (result, {fetchMore, refetch}) {
                    if (result.isLoading && result.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (result.hasException) {
                      return Center(child: Text('Error: ${result.exception.toString()}'));
                    }

                    final participants = result.data!['challenge']['participants'] as List;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final p = participants[index];
                        final user = p['user'];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['avatarUrl']),
                          ),
                          title: Text(user['displayName']),
                          subtitle: Text("🔥 ${p['dailyStreak'] ?? 0} week streak"),
                          trailing: Text(p['role']),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
