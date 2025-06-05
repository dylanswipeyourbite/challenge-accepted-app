import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:lottie/lottie.dart';
import 'package:challengeaccepted/models/badge.dart';
import 'package:challengeaccepted/models/challenge_milestone.dart';

class EnhancedSuccessDialog extends StatefulWidget {
  final int pointsEarned;
  final int newStreak;
  final String challengeTitle;
  final List<BadgeEarned>? newBadges;
  final ChallengeMilestone? milestone;
  final VoidCallback onComplete;
  final VoidCallback? onShare;
  
  const EnhancedSuccessDialog({
    super.key,
    required this.pointsEarned,
    required this.newStreak,
    required this.challengeTitle,
    this.newBadges,
    this.milestone,
    required this.onComplete,
    this.onShare,
  });
  
  @override
  State<EnhancedSuccessDialog> createState() => _EnhancedSuccessDialogState();
}

class _EnhancedSuccessDialogState extends State<EnhancedSuccessDialog>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _scaleController.forward();
    _slideController.forward();
    
    // Trigger confetti for special achievements
    if (widget.newStreak >= 7 || widget.newBadges?.isNotEmpty == true || widget.milestone != null) {
      _confettiController.play();
    }
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main content
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildContent(),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                  Colors.pink,
                ],
                numberOfParticles: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final bool isMilestone = widget.milestone != null;
    final bool hasNewBadge = widget.newBadges?.isNotEmpty == true;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMilestone
              ? [Colors.purple.shade400, Colors.purple.shade600]
              : hasNewBadge
                  ? [Colors.orange.shade400, Colors.orange.shade600]
                  : [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Animated icon or lottie animation
          if (isMilestone)
            Lottie.asset(
              'assets/animations/trophy.json',
              width: 100,
              height: 100,
              repeat: false,
            )
          else if (hasNewBadge)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * 3.14159,
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 80,
                  ),
                );
              },
            )
          else
            const Icon(
              Icons.celebration,
              color: Colors.white,
              size: 80,
            ),
          
          const SizedBox(height: 16),
          Text(
            _getHeaderTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Points and streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AnimatedStatCard(
                icon: Icons.star,
                value: '+${widget.pointsEarned}',
                label: 'Points',
                color: Colors.amber,
                delay: 200,
              ),
              _AnimatedStatCard(
                icon: Icons.local_fire_department,
                value: '${widget.newStreak}',
                label: 'Day Streak',
                color: Colors.orange,
                delay: 400,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Challenge info
          Text(
            'Completed: ${widget.challengeTitle}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Milestone achieved
          if (widget.milestone != null) ...[
            const SizedBox(height: 16),
            _MilestoneCard(milestone: widget.milestone!),
          ],
          
          // New badges
          if (widget.newBadges?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            const Text(
              'New Badges Earned! 🎖️',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: widget.newBadges!.map((badge) => _BadgeChip(badge: badge)).toList(),
            ),
          ],
          
          // Motivational message
          const SizedBox(height: 16),
          Text(
            _getMotivationalMessage(),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (widget.onShare != null)
            OutlinedButton.icon(
              onPressed: widget.onShare,
              icon: const Icon(Icons.share),
              label: const Text('Share Achievement'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onComplete();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getHeaderTitle() {
    if (widget.milestone != null) {
      return 'Milestone Unlocked! 🎯';
    } else if (widget.newBadges?.isNotEmpty == true) {
      return 'New Badge${widget.newBadges!.length > 1 ? 's' : ''} Earned! 🏅';
    } else if (widget.newStreak >= 30) {
      return 'Legendary Streak! 👑';
    } else if (widget.newStreak >= 7) {
      return 'Week Warrior! 🔥';
    } else {
      final titles = [
        'Amazing Work! 💪',
        'You\'re Crushing It! 🔥',
        'Keep That Momentum! 🚀',
        'Consistency Champion! 🏆',
        'Way to Show Up! ⭐',
      ];
      return titles[widget.pointsEarned % titles.length];
    }
  }
  
  String _getMotivationalMessage() {
    final messages = [
      '"Success is the sum of small efforts repeated day in and day out."',
      '"The only bad workout is the one that didn\'t happen."',
      '"Your only limit is you."',
      '"Progress, not perfection."',
      '"Every champion was once a contender who refused to give up."',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
}

class _AnimatedStatCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final int delay;
  
  const _AnimatedStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
  });
  
  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Icon(widget.icon, color: widget.color, size: 32),
          const SizedBox(height: 4),
          Text(
            widget.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ),
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Milestone Card
class _MilestoneCard extends StatelessWidget {
  final ChallengeMilestone milestone;
  
  const _MilestoneCard({required this.milestone});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            milestone.name,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Badge Chip
class _BadgeChip extends StatelessWidget {
  final BadgeEarned badge;
  
  const _BadgeChip({required this.badge});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge.badge.icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 6),
          Text(
            badge.badge.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}