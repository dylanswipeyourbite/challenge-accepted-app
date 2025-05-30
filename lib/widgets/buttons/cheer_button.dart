import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/mutations/media_mutations.dart';

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
    required this.onRefetch,
  });

  @override
  State<CheerButton> createState() => _CheerButtonState();
}

class _CheerButtonState extends State<CheerButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool? _optimisticCheer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCheer(RunMutation runMutation) {
    final willCheer = !(_optimisticCheer ?? widget.hasCheered);
    
    // Optimistic update
    setState(() {
      _optimisticCheer = willCheer;
    });
    
    // Animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    runMutation({'mediaId': widget.mediaId});
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHasCheered = _optimisticCheer ?? widget.hasCheered;
    final effectiveCheers = widget.cheers.length + 
      ((_optimisticCheer != null && _optimisticCheer != widget.hasCheered) 
        ? (_optimisticCheer! ? 1 : -1) 
        : 0);

    return Mutation(
      options: MutationOptions(
        document: gql(effectiveHasCheered
            ? MediaMutations.uncheerPostMutation
            : MediaMutations.cheerPostMutation),
        onCompleted: (_) {
          // Reset optimistic state after success
          setState(() => _optimisticCheer = null);
          // Optionally refresh the parent
          widget.onRefetch?.call();
        },
        onError: (error) {
          // Rollback optimistic update
          setState(() => _optimisticCheer = null);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not update cheer'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
      builder: (runMutation, result) {
        return GestureDetector(
          onTap: result?.isLoading ?? false ? null : () => _toggleCheer(runMutation),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    effectiveHasCheered
                        ? Icons.emoji_emotions
                        : Icons.emoji_emotions_outlined,
                    color: effectiveHasCheered ? Colors.orange : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$effectiveCheers Cheer${effectiveCheers == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: effectiveHasCheered ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}