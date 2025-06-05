// File: lib/pages/challenge_analytics_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/graphql/queries/analytics_queries.dart';

class ChallengeAnalyticsPage extends StatefulWidget {
  final String challengeId;
  
  const ChallengeAnalyticsPage({
    super.key,
    required this.challengeId,
  });
  
  @override
  State<ChallengeAnalyticsPage> createState() => _ChallengeAnalyticsPageState();
}

class _ChallengeAnalyticsPageState extends State<ChallengeAnalyticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Progress'),
            Tab(text: 'Records'),
            Tab(text: 'Patterns'),
          ],
        ),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(AnalyticsQueries.getChallengeAnalytics),
          variables: {'challengeId': widget.challengeId},
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
        builder: (result, {refetch, fetchMore}) {
          if (result.isLoading && result.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (result.hasException) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${result.exception}'),
                  ElevatedButton(
                    onPressed: refetch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final analytics = result.data?['challengeAnalytics'];
          if (analytics == null) {
            return const Center(child: Text('No analytics data available'));
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(data: analytics['overview']),
              _ProgressTab(
                weeklyData: analytics['weeklyProgress'] ?? [],
                activityDistribution: analytics['activityDistribution'] ?? [],
              ),
              _RecordsTab(records: analytics['personalRecords'] ?? []),
              _PatternsTab(patterns: analytics['patterns'] ?? {}),
            ],
          );
        },
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const _OverviewTab({required this.data});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _SummaryCard(
                title: 'Total Days',
                value: '${data['totalDays'] ?? 0}',
                icon: Icons.calendar_today,
                color: Colors.blue,
              ),
              _SummaryCard(
                title: 'Active Days',
                value: '${data['activeDays'] ?? 0}',
                icon: Icons.fitness_center,
                color: Colors.green,
              ),
              _SummaryCard(
                title: 'Total Points',
                value: '${data['totalPoints'] ?? 0}',
                icon: Icons.star,
                color: Colors.amber,
              ),
              _SummaryCard(
                title: 'Longest Streak',
                value: '${data['longestStreak'] ?? 0} days',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Activity breakdown pie chart
          const Text(
            'Activity Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _ActivityPieChart(
              activeDays: data['activeDays'] ?? 0,
              restDays: data['restDays'] ?? 0,
              missedDays: data['missedDays'] ?? 0,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats list
          _StatsList(data: data),
        ],
      ),
    );
  }
}

// Missing _SummaryCard widget
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityPieChart extends StatelessWidget {
  final int activeDays;
  final int restDays;
  final int missedDays;
  
  const _ActivityPieChart({
    required this.activeDays,
    required this.restDays,
    required this.missedDays,
  });
  
  @override
  Widget build(BuildContext context) {
    final total = activeDays + restDays + missedDays;
    if (total == 0) return const Center(child: Text('No data'));
    
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: activeDays.toDouble(),
            title: '${(activeDays / total * 100).toStringAsFixed(0)}%',
            color: Colors.green,
            radius: 100,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          PieChartSectionData(
            value: restDays.toDouble(),
            title: '${(restDays / total * 100).toStringAsFixed(0)}%',
            color: Colors.blue,
            radius: 100,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (missedDays > 0)
            PieChartSectionData(
              value: missedDays.toDouble(),
              title: '${(missedDays / total * 100).toStringAsFixed(0)}%',
              color: Colors.red,
              radius: 100,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}

// Missing _StatsList widget
class _StatsList extends StatelessWidget {
  final Map<String, dynamic> data;
  
  const _StatsList({required this.data});
  
  @override
  Widget build(BuildContext context) {
    final avgPoints = data['averagePointsPerDay'] ?? 0.0;
    final currentStreak = data['currentStreak'] ?? 0;
    
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.trending_up, color: Colors.purple),
          title: const Text('Average Points/Day'),
          trailing: Text(
            avgPoints.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.whatshot, color: Colors.deepOrange),
          title: const Text('Current Streak'),
          trailing: Text(
            '$currentStreak days',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Progress Tab
class _ProgressTab extends StatelessWidget {
  final List<dynamic> weeklyData;
  final List<dynamic> activityDistribution;
  
  const _ProgressTab({
    required this.weeklyData,
    required this.activityDistribution,
  });
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: _WeeklyProgressChart(data: weeklyData),
          ),
          const SizedBox(height: 24),
          const Text(
            'Activity Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...activityDistribution.map((activity) => _ActivityBar(
            type: activity['type'] ?? '',
            count: activity['count'] ?? 0,
            percentage: activity['percentage'] ?? 0.0,
          )).toList(),
        ],
      ),
    );
  }
}

// Weekly Progress Chart
class _WeeklyProgressChart extends StatelessWidget {
  final List<dynamic> data;
  
  const _WeeklyProgressChart({required this.data});
  
  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No weekly data available'));
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final week = data[groupIndex];
              return BarTooltipItem(
                'Week ${week['week']}\n${rod.toY.toInt()} points',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  return Text('W${data[value.toInt()]['week']}');
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _createBarGroups(),
      ),
    );
  }
  
  double _getMaxY() {
    double max = 0;
    for (final week in data) {
      final points = (week['points'] ?? 0).toDouble();
      if (points > max) max = points;
    }
    return max * 1.2; // Add 20% padding
  }
  
  List<BarChartGroupData> _createBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final week = entry.value;
      final points = (week['points'] ?? 0).toDouble();
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: points,
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}

// Activity Bar
class _ActivityBar extends StatelessWidget {
  final String type;
  final int count;
  final double percentage;
  
  const _ActivityBar({
    required this.type,
    required this.count,
    required this.percentage,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('$count (${percentage.toStringAsFixed(1)}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_getColorForType(type)),
          ),
        ],
      ),
    );
  }
  
  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Colors.orange;
      case 'cycling':
        return Colors.blue;
      case 'workout':
        return Colors.purple;
      default:
        return Colors.green;
    }
  }
}

// Records Tab
class _RecordsTab extends StatelessWidget {
  final List<dynamic> records;
  
  const _RecordsTab({required this.records});
  
  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No personal records yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Keep pushing to set new records!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return _RecordCard(
          type: record['type'] ?? '',
          value: record['value'] ?? 0,
          date: record['date'] != null 
              ? DateTime.parse(record['date']) 
              : DateTime.now(),
          description: record['description'] ?? '',
        );
      },
    );
  }
}

// Record Card
class _RecordCard extends StatelessWidget {
  final String type;
  final int value;
  final DateTime date;
  final String description;
  
  const _RecordCard({
    required this.type,
    required this.value,
    required this.date,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForRecord(),
          child: Icon(_getIconForRecord(), color: Colors.white),
        ),
        title: Text(
          _getTitleForRecord(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getColorForRecord() {
    switch (type) {
      case 'longest_streak':
        return Colors.orange;
      case 'max_points_day':
        return Colors.green;
      case 'max_weekly_activities':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }
  
  IconData _getIconForRecord() {
    switch (type) {
      case 'longest_streak':
        return Icons.local_fire_department;
      case 'max_points_day':
        return Icons.star;
      case 'max_weekly_activities':
        return Icons.fitness_center;
      default:
        return Icons.emoji_events;
    }
  }
  
  String _getTitleForRecord() {
    switch (type) {
      case 'longest_streak':
        return 'Longest Streak';
      case 'max_points_day':
        return 'Best Day';
      case 'max_weekly_activities':
        return 'Most Active Week';
      default:
        return 'Personal Record';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Patterns Tab
class _PatternsTab extends StatelessWidget {
  final Map<String, dynamic> patterns;
  
  const _PatternsTab({required this.patterns});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Activity Patterns',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _PatternCard(
            icon: Icons.calendar_today,
            title: 'Most Active Day',
            value: patterns['mostActiveDay'] ?? 'No data',
            color: Colors.blue,
          ),
          _PatternCard(
            icon: Icons.access_time,
            title: 'Preferred Time',
            value: patterns['mostActiveTime'] ?? 'No data',
            color: Colors.orange,
          ),
          _PatternCard(
            icon: Icons.sports,
            title: 'Favorite Activity',
            value: patterns['preferredActivity'] ?? 'No data',
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _InsightCard(patterns: patterns),
        ],
      ),
    );
  }
}

// Pattern Card
class _PatternCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  
  const _PatternCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          value.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Insight Card
class _InsightCard extends StatelessWidget {
  final Map<String, dynamic> patterns;
  
  const _InsightCard({required this.patterns});
  
  String _getInsight() {
    final day = patterns['mostActiveDay'];
    final time = patterns['mostActiveTime'];
    final activity = patterns['preferredActivity'];
    
    if (day == 'No data') {
      return 'Start logging activities to discover your patterns!';
    }
    
    return 'You tend to be most active on ${day}s during the $time. '
           'Your go-to activity is $activity. Keep it up!';
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getInsight(),
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }
}