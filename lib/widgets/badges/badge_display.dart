// lib/widgets/badges/badge_display.dart
import 'package:challengeaccepted/services/gamification_service.dart';
import 'package:flutter/material.dart';
import 'package:challengeaccepted/models/badge.dart';
import 'package:challengeaccepted/services/badge_service_integration.dart';

class BadgeDisplay extends StatefulWidget {
  final bool showProgress;
  final bool showAllBadges;
  
  const BadgeDisplay({
    super.key,
    this.showProgress = true,
    this.showAllBadges = false,
  });
  
  @override
  State<BadgeDisplay> createState() => _BadgeDisplayState();
}

class _BadgeDisplayState extends State<BadgeDisplay> {
  BadgeProgressData? _badgeData;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBadges();
  }
  
  Future<void> _loadBadges() async {
    try {
      final badgeService = context.badgeService;
      final data = await badgeService.getUserBadgeProgress();
      
      if (mounted) {
        setState(() {
          _badgeData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_badgeData == null) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showProgress) _buildProgressSection(),
        const SizedBox(height: 24),
        _buildEarnedBadges(),
        if (widget.showProgress && _badgeData!.nextBadges.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildNextBadges(),
        ],
        if (widget.showAllBadges) ...[
          const SizedBox(height: 24),
          _buildAllBadges(),
        ],
      ],
    );
  }
  
  Widget _buildProgressSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Badge Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_badgeData!.earnedBadges.length} / ${GamificationService.badges.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Badges Earned',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _badgeData!.totalProgress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '${(_badgeData!.totalProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarnedBadges() {
    if (_badgeData!.earnedBadges.isEmpty) {
      return _EmptyBadgesMessage();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Badges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: _badgeData!.earnedBadges.length,
          itemBuilder: (context, index) {
            final badge = _badgeData!.earnedBadges[index];
            return _BadgeItem(
              badge: badge.badge,
              earnedAt: badge.earnedAt,
              onTap: () => _showBadgeDetails(badge),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildNextBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Badges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _badgeData!.nextBadges.length > 3 ? 3 : _badgeData!.nextBadges.length,
          (index) {
            final progress = _badgeData!.nextBadges[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BadgeProgressCard(progress: progress),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildAllBadges() {
    final allBadges = GamificationService.badges;
    final earnedIds = _badgeData!.earnedBadges.map((b) => b.badgeId).toSet();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'All Badges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: allBadges.length,
          itemBuilder: (context, index) {
            final badge = allBadges[index];
            final isEarned = earnedIds.contains(badge.id);
            
            return _BadgeItem(
              badge: badge,
              isEarned: isEarned,
              onTap: () => _showBadgeInfo(badge, isEarned),
            );
          },
        ),
      ],
    );
  }
  
  void _showBadgeDetails(BadgeEarned badge) {
    showDialog(
      context: context,
      builder: (context) => _BadgeDetailsDialog(
        badge: badge.badge,
        earnedAt: badge.earnedAt,
      ),
    );
  }
  
  void _showBadgeInfo(BadgeDefinition badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => _BadgeInfoDialog(
        badge: badge,
        isEarned: isEarned,
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeDefinition badge;
  final DateTime? earnedAt;
  final bool isEarned;
  final VoidCallback onTap;
  
  const _BadgeItem({
    required this.badge,
    this.earnedAt,
    this.isEarned = true,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isEarned ? _getCategoryColor(badge.category) : Colors.grey.shade300,
              shape: BoxShape.circle,
              boxShadow: isEarned
                  ? [
                      BoxShadow(
                        color: _getCategoryColor(badge.category).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                badge.icon,
                style: TextStyle(
                  fontSize: 28,
                  color: isEarned ? null : Colors.grey.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isEarned ? FontWeight.w600 : FontWeight.normal,
              color: isEarned ? null : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.milestone:
        return Colors.blue;
      case BadgeCategory.streak:
        return Colors.orange;
      case BadgeCategory.points:
        return Colors.amber;
      case BadgeCategory.social:
        return Colors.purple;
      case BadgeCategory.special:
        return Colors.teal;
    }
  }
}

class _BadgeProgressCard extends StatelessWidget {
  final BadgeProgress progress;
  
  const _BadgeProgressCard({
    required this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                progress.badge.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.badge.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progress.badge.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress.progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(progress.progress),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.currentValue}/${progress.targetValue}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
}

class _EmptyBadgesMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No badges earned yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete activities to earn your first badge!',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeDetailsDialog extends StatelessWidget {
  final BadgeDefinition badge;
  final DateTime earnedAt;
  
  const _BadgeDetailsDialog({
    required this.badge,
    required this.earnedAt,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getCategoryColor(badge.category),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Earned ${_formatDate(earnedAt)}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.milestone:
        return Colors.blue;
      case BadgeCategory.streak:
        return Colors.orange;
      case BadgeCategory.points:
        return Colors.amber;
      case BadgeCategory.social:
        return Colors.purple;
      case BadgeCategory.special:
        return Colors.teal;
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return 'on ${date.day}/${date.month}/${date.year}';
    }
  }
}

class _BadgeInfoDialog extends StatelessWidget {
  final BadgeDefinition badge;
  final bool isEarned;
  
  const _BadgeInfoDialog({
    required this.badge,
    required this.isEarned,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isEarned 
                    ? _getCategoryColor(badge.category)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 40,
                    color: isEarned ? null : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCriteriaIcon(badge.criteria.type),
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getCriteriaText(badge.criteria),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.milestone:
        return Colors.blue;
      case BadgeCategory.streak:
        return Colors.orange;
      case BadgeCategory.points:
        return Colors.amber;
      case BadgeCategory.social:
        return Colors.purple;
      case BadgeCategory.special:
        return Colors.teal;
    }
  }
  
  IconData _getCriteriaIcon(String type) {
    switch (type) {
      case 'activities':
        return Icons.fitness_center;
      case 'streak':
        return Icons.local_fire_department;
      case 'points':
        return Icons.star;
      case 'cheers':
        return Icons.favorite;
      case 'team_streak':
        return Icons.group;
      case 'early_logs':
        return Icons.access_time;
      case 'rest_optimization':
        return Icons.bed;
      default:
        return Icons.flag;
    }
  }
  
  String _getCriteriaText(BadgeCriteria criteria) {
    switch (criteria.type) {
      case 'activities':
        return 'Complete ${criteria.value} activities';
      case 'streak':
        return 'Maintain a ${criteria.value} day streak';
      case 'points':
        return 'Earn ${criteria.value} points';
      case 'cheers':
        return 'Give ${criteria.value} cheers';
      case 'team_streak':
        return '${criteria.value} day team streak';
      case 'early_logs':
        return 'Log ${criteria.value} times before 9 AM';
      case 'rest_optimization':
        return 'Optimize rest for ${criteria.value} weeks';
      default:
        return 'Complete the challenge';
    }
  }
}