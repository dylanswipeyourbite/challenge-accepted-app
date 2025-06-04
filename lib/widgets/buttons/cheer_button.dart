// lib/widgets/buttons/provider_aware_cheer_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/models/media.dart';
import 'package:challengeaccepted/providers/user_activity_provider.dart';
import 'package:challengeaccepted/graphql/mutations/media_mutations.dart';

class CheerButton extends StatefulWidget {
  final Media media;

  const CheerButton({
    super.key,
    required this.media,
  });

  @override
  State<CheerButton> createState() => _CheerButtonState();
}

class _CheerButtonState extends State<CheerButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool? _optimisticCheer;
  bool _isProcessing = false;

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

  Future<void> _toggleCheer() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    final provider = context.read<UserActivityProvider>();
    final client = GraphQLProvider.of(context).value;
    final willCheer = !(_optimisticCheer ?? widget.media.hasCheered);
    
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
    
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(willCheer
              ? MediaMutations.cheerPostMutation
              : MediaMutations.uncheerPostMutation),
          variables: {'mediaId': widget.media.id},
        ),
      );
      
      if (!result.hasException) {
        // Update provider with new cheer state
        provider.updateMediaInteraction(
          widget.media.id,
          hasCheered: willCheer,
        );
      } else {
        // Rollback optimistic update
        setState(() => _optimisticCheer = null);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not update cheer'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Rollback optimistic update
      setState(() => _optimisticCheer = null);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHasCheered = _optimisticCheer ?? widget.media.hasCheered;
    final effectiveCheers = widget.media.cheerCount + 
      ((_optimisticCheer != null && _optimisticCheer != widget.media.hasCheered) 
        ? (_optimisticCheer! ? 1 : -1) 
        : 0);

    return GestureDetector(
      onTap: _toggleCheer,
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
  }
}