// File: lib/pages/challenge_calendar_page.dart

import 'package:challengeaccepted/models/challenge_enums.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:challengeaccepted/models/daily_log.dart';

class ChallengeCalendarPage extends StatefulWidget {
  final String challengeId;
  
  const ChallengeCalendarPage({
    super.key,
    required this.challengeId,
  });
  
  @override
  State<ChallengeCalendarPage> createState() => _ChallengeCalendarPageState();
}

class _ChallengeCalendarPageState extends State<ChallengeCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  static const String getDailyLogsQuery = """
    query GetDailyLogs(\$challengeId: ID!) {
      dailyLogs(challengeId: \$challengeId) {
        id
        date
        type
        activityType
        points
        notes
        media {
          id
          url
          type
        }
      }
    }
  """;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showLegend,
          ),
        ],
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getDailyLogsQuery),
          variables: {'challengeId': widget.challengeId},
        ),
        builder: (result, {refetch, fetchMore}) {
          if (result.isLoading && result.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final logs = _parseDailyLogs(result.data?['dailyLogs'] ?? []);
          final logsByDate = _groupLogsByDate(logs);
          
          return Column(
            children: [
              _buildCalendar(logsByDate),
              const Divider(),
              Expanded(
                child: _buildSelectedDayDetails(logsByDate),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildCalendar(Map<DateTime, List<DailyLog>> logsByDate) {
    return TableCalendar<DailyLog>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        return logsByDate[normalizedDay] ?? [];
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        markersMaxCount: 3,
        markerDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade400,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          
          final logs = events.cast<DailyLog>();
          final hasActivity = logs.any((log) => log.type == LogType.activity);
          final hasRest = logs.any((log) => log.type == LogType.rest);
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasActivity)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              if (hasRest)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
            ],
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }
  
  Widget _buildSelectedDayDetails(Map<DateTime, List<DailyLog>> logsByDate) {
    if (_selectedDay == null) {
      return const Center(
        child: Text(
          'Select a day to view details',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final logs = logsByDate[normalizedDay] ?? [];
    
    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No activity on ${_formatDate(_selectedDay!)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _DayLogCard(log: log);
      },
    );
  }
  
  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LegendItem(
              color: Colors.green,
              label: 'Activity Day',
              description: 'Logged workout or exercise',
            ),
            _LegendItem(
              color: Colors.blue,
              label: 'Rest Day',
              description: 'Logged rest day',
            ),
            _LegendItem(
              color: Colors.red,
              label: 'Missed Day',
              description: 'No activity logged',
            ),
            _LegendItem(
              color: Colors.yellow,
              label: 'Personal Record',
              description: 'Achieved a milestone',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
  
  List<DailyLog> _parseDailyLogs(List<dynamic> data) {
    return data.map((json) => DailyLog.fromJson(json)).toList();
  }
  
  Map<DateTime, List<DailyLog>> _groupLogsByDate(List<DailyLog> logs) {
    final Map<DateTime, List<DailyLog>> grouped = {};
    
    for (final log in logs) {
      final date = DateTime(log.date.year, log.date.month, log.date.day);
      grouped.putIfAbsent(date, () => []).add(log);
    }
    
    return grouped;
  }
  
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// Missing widgets for ChallengeCalendarPage

// Day Log Card widget
class _DayLogCard extends StatelessWidget {
  final DailyLog log;
  
  const _DayLogCard({required this.log});
  
  @override
  Widget build(BuildContext context) {
    final isActivity = log.type == LogType.activity;
    final color = isActivity ? Colors.green : Colors.blue;
    final icon = isActivity ? Icons.fitness_center : Icons.bed;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              isActivity ? 'Activity: ${log.activityType?.name ?? 'General'}' : 'Rest Day',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${log.points} points earned'),
            trailing: Chip(
              label: Text(
                _formatTime(log.createdAt),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          if (log.notes != null && log.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.notes!,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          if (log.media != null && log.media!.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: log.media!.length,
                itemBuilder: (context, index) {
                  final media = log.media![index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        media.url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Legend Item widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String description;
  
  const _LegendItem({
    required this.color,
    required this.label,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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