import 'package:challengeaccepted/graphql/mutations/media_mutations.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CheerButton extends StatefulWidget {
  final String mediaId;
  final List cheers;
  final bool hasCheered;
  final VoidCallback? onRefetch;

  const CheerButton({
    super.key,
    required this.mediaId,
    required this.cheers,
    required this.hasCheered,
    required this.onRefetch
  });

  @override
  State<CheerButton> createState() => _CheerButtonState();
}

class _CheerButtonState extends State<CheerButton> with SingleTickerProviderStateMixin {
  double _iconScale = 1.0;
  bool? optimisticCheer;

  void animate() {
    setState(() => _iconScale = 1.4);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _iconScale = 1.0);
    });
  }

  void toggleCheer(RunMutation runMutation) {
    final optimistic = !(optimisticCheer ?? widget.hasCheered);
    runMutation({'mediaId': widget.mediaId});

    setState(() {
      optimisticCheer = optimistic;
    });

    animate();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHasCheered = optimisticCheer ?? widget.hasCheered;
    final cheerCount = widget.cheers.length + (optimisticCheer == null
        ? 0
        : (optimisticCheer! ? 1 : -1) * (widget.hasCheered ? 0 : 1));

    return Mutation(
      options: MutationOptions(
        document: gql(effectiveHasCheered
            ? MediaMutations.uncheerPostMutation
            : MediaMutations.cheerPostMutation),
        onCompleted: (_) async {
          setState(() => optimisticCheer = null);
          widget.onRefetch?.call(); 
        },
      ),
      builder: (runMutation, result) {
        return GestureDetector(
          onTap: () => toggleCheer(runMutation),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: _iconScale,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  effectiveHasCheered
                      ? Icons.emoji_emotions
                      : Icons.emoji_emotions_outlined,
                  color: effectiveHasCheered ? Colors.orange : Colors.grey,
                ),
              ),
              const SizedBox(width: 6),
              Text('$cheerCount Cheer${cheerCount == 1 ? '' : 's'}'),
            ],
          ),
        );
      },
    );
  }
}
