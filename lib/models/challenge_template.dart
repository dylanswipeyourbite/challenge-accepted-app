// lib/models/challenge_template.dart

import 'package:challengeaccepted/models/challenge_milestone.dart';
import 'package:flutter/material.dart';

class ChallengeTemplate {
  final String id;
  final String name;  // This becomes 'title' in the form
  final String description;
  final String category;
  final IconData icon;
  final List<String> defaultRules;  // This becomes 'rules' in the form
  final List<ChallengeMilestone> suggestedMilestones;
  final int suggestedDuration; // in days
  final List<String> activityTypes;  // This becomes 'allowedActivities'
  final int? suggestedRestDaysPerWeek;
  final int minWeeklyActivities;  // Add this
  final String sport;  // Add this
  final String type;

  const ChallengeTemplate({
  required this.id,
  required this.name, // This becomes 'title' in the form
  required this.description,
  required this.category,
  required this.icon,
  required this.defaultRules, // This becomes 'rules' in the form
  required this.suggestedMilestones,
  required this.suggestedDuration, // in days
  required this.activityTypes,  // This becomes 'allowedActivities'
  required this.suggestedRestDaysPerWeek,
  required this.minWeeklyActivities,  // Add this
  required this.sport,  // Add this
  required this.type,
  });

  static List<ChallengeTemplate> get popularTemplates => [
  ChallengeTemplate(
    id: 'marathon_training',
    name: 'Marathon Training',
    description: 'Prepare for your marathon with structured training',
    category: 'Running',
    icon: Icons.directions_run,
    sport: 'running',  // Add this
    type: 'collaborative',  // Add this
    minWeeklyActivities: 4,  // Add this
    defaultRules: [
      'Run at least 4 times per week',
      'Include one long run per week',
      'Log all activities with distance and time',
      'Rest days are mandatory for recovery',
    ],
    suggestedMilestones: [
      ChallengeMilestone(
        id: 'first_10k',
        name: 'First 10K',
        type: 'custom',
        target: 1,
        description: 'Complete your first 10K run',
      ),
      ChallengeMilestone(
        id: 'half_marathon',
        name: 'Half Marathon Distance',
        type: 'custom',
        target: 1,
        description: 'Run 21.1 km in a single session',
      ),
      ChallengeMilestone(
        id: 'total_distance',
        name: '100 Miles Total',
        type: 'custom',
        target: 160, // km
        description: 'Accumulate 160 km of running',
      ),
    ],
    suggestedDuration: 90,
    activityTypes: ['Running'],
    suggestedRestDaysPerWeek: 2,
  ),
  
  ChallengeTemplate(
    id: '30_day_fitness',
    name: '30-Day Fitness',
    description: 'Build a consistent fitness habit in 30 days',
    category: 'General Fitness',
    icon: Icons.fitness_center,
    sport: 'workout',  // Add this
    type: 'competitive',  // Add this
    minWeeklyActivities: 5,  // Add this
    defaultRules: [
      'Complete at least one activity per day',
      'Activities must be at least 30 minutes',
      'Mix different types of exercises',
      'Submit photo proof for each activity',
    ],
    suggestedMilestones: [
      ChallengeMilestone(
        id: 'week_1',
        name: 'First Week Complete',
        type: 'streak',
        target: 7,
        description: 'Complete 7 consecutive days',
      ),
      ChallengeMilestone(
        id: 'points_100',
        name: 'Century Club',
        type: 'points',
        target: 100,
        description: 'Earn 100 points total',
      ),
      ChallengeMilestone(
        id: 'activities_20',
        name: 'Activity Master',
        type: 'activities',
        target: 20,
        description: 'Complete 20 activities',
      ),
    ],
    suggestedDuration: 30,
    activityTypes: ['Gym', 'Running', 'Cycling', 'Yoga', 'Swimming', 'Other'],
    suggestedRestDaysPerWeek: 1,
  ),
  
  ChallengeTemplate(
    id: 'weight_loss',
    name: 'Weight Loss Journey',
    description: 'Sustainable weight loss through consistent exercise',
    category: 'Health',
    icon: Icons.monitor_weight,
    sport: 'workout',  // Add this
    type: 'collaborative',  // Add this
    minWeeklyActivities: 5,  // Add this
    defaultRules: [
      'Exercise at least 5 days per week',
      'Track weight weekly',
      'Mix cardio and strength training',
      'Log meals in addition to activities',
    ],
    suggestedMilestones: [
      ChallengeMilestone(
        id: 'first_5_pounds',
        name: 'First 5 Pounds',
        type: 'custom',
        target: 5,
        description: 'Lose first 5 pounds',
      ),
      ChallengeMilestone(
        id: 'consistency',
        name: 'Consistency King',
        type: 'streak',
        target: 14,
        description: '14-day activity streak',
      ),
      ChallengeMilestone(
        id: 'cardio_master',
        name: 'Cardio Master',
        type: 'custom',
        target: 600, // minutes
        description: '600 minutes of cardio',
      ),
    ],
    suggestedDuration: 60,
    activityTypes: ['Gym', 'Running', 'Cycling', 'Swimming', 'Walking'],
    suggestedRestDaysPerWeek: 2,
  ),
  
  ChallengeTemplate(
    id: 'yoga_journey',
    name: 'Yoga Journey',
    description: 'Deepen your yoga practice with daily sessions',
    category: 'Mindfulness',
    icon: Icons.self_improvement,
    sport: 'yoga',  // Add this
    type: 'collaborative',  // Add this
    minWeeklyActivities: 7,  // Add this (daily practice)
    defaultRules: [
      'Practice yoga daily',
      'Sessions must be at least 20 minutes',
      'Try different yoga styles',
      'Focus on breath and mindfulness',
    ],
    suggestedMilestones: [
      ChallengeMilestone(
        id: 'first_week',
        name: 'First Week',
        type: 'streak',
        target: 7,
        description: 'Complete first week',
      ),
      ChallengeMilestone(
        id: 'morning_routine',
        name: 'Morning Yogi',
        type: 'custom',
        target: 10,
        description: '10 morning sessions',
      ),
      ChallengeMilestone(
        id: 'flexibility',
        name: 'Flexibility Goals',
        type: 'custom',
        target: 1,
        description: 'Touch your toes!',
      ),
    ],
    suggestedDuration: 30,
    activityTypes: ['Yoga'],
    suggestedRestDaysPerWeek: 0,
  ),
  
  ChallengeTemplate(
    id: 'cycling_century',
    name: 'Cycling Century',
    description: 'Build up to riding 100 miles',
    category: 'Cycling',
    icon: Icons.directions_bike,
    sport: 'cycling',  // Add this
    type: 'collaborative',  // Add this
    minWeeklyActivities: 3,  // Add this
    defaultRules: [
      'Ride at least 3 times per week',
      'Track distance and elevation',
      'Include one long ride per week',
      'Maintain your bike regularly',
    ],
    suggestedMilestones: [
      ChallengeMilestone(
        id: 'first_50k',
        name: 'First 50K',
        type: 'custom',
        target: 1,
        description: 'Complete a 50km ride',
      ),
      ChallengeMilestone(
        id: 'climbing',
        name: 'Mountain Goat',
        type: 'custom',
        target: 5000, // meters
        description: 'Climb 5000m total',
      ),
      ChallengeMilestone(
        id: 'century',
        name: 'Century Ride',
        type: 'custom',
        target: 1,
        description: 'Complete 100 miles in one ride',
      ),
    ],
    suggestedDuration: 60,
    activityTypes: ['Cycling'],
    suggestedRestDaysPerWeek: 2,
  ),
  ];
  
  Map<String, dynamic> toMap() {
    return {
      'title': name,  // Map 'name' to 'title' for backend
      'description': description,
      'rules': defaultRules, // Send as array, backend now expects array
      'milestones': suggestedMilestones.map((m) => m.toMap()).toList(),
      'duration': suggestedDuration,
      'allowedActivities': activityTypes,  // Map 'activityTypes' to 'allowedActivities'
      'restDaysPerWeek': suggestedRestDaysPerWeek,
      'minWeeklyActivities': minWeeklyActivities,
      'sport': sport,
      'type': type,
    };
  }
}