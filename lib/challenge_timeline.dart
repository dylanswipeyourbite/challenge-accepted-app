import 'package:flutter/material.dart';

class ChallengeMediaGallery extends StatelessWidget {
  final List<dynamic> mediaList;

  const ChallengeMediaGallery({required this.mediaList, super.key});

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) {
      return const Text("No media uploaded yet.");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final media = mediaList[index];
        final url = media['url'];
        final type = media['type'];

        return GestureDetector(
          onTap: () {
            // Optional: Open preview
            showDialog(
              context: context,
              builder: (_) => Dialog(
                child: type == 'photo'
                  ? Image.network(url, fit: BoxFit.cover)
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(url, fit: BoxFit.cover),
                        const Icon(Icons.play_circle, size: 64, color: Colors.white),
                      ],
                    ),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              if (type == 'video')
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
            ],
          ),
        );
      },
    );
  }
}

class ChallengeMediaViewer extends StatelessWidget {
  final List<dynamic> mediaList;
  final int initialIndex;

  const ChallengeMediaViewer({
    required this.mediaList,
    this.initialIndex = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final media = mediaList[index];
              final url = media['url'];
              final type = media['type'];

              return Center(
                child: type == 'photo'
                    ? Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const CircularProgressIndicator();
                        },
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            url,
                            fit: BoxFit.contain,
                          ),
                          const Icon(
                            Icons.play_circle_fill,
                            size: 80,
                            color: Colors.white,
                          )
                        ],
                      ),
              );
            },
          ),

          // Close Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          )
        ],
      ),
    );
  }
}
