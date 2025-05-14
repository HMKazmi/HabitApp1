import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../services/storage_service.dart';

class HabitViewModel extends ChangeNotifier {
  final HabitStorageService _storage = HabitStorageService();
  List<Habit> _habits = [];

  HabitViewModel() {
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    await _storage.init();
    _loadHabits();
  }

  void _loadHabits() {
    _habits = _storage.getAllHabits();
    notifyListeners();
  }

  // Getters
  List<Habit> get habits => _habits;

  // Get habits that should be completed today based on frequency
  List<Habit> getTodayHabits() {
    final now = DateTime.now();
    return _habits.where((habit) {
      switch (habit.frequency) {
        case HabitFrequency.daily:
          return true;
        case HabitFrequency.weekly:
          return now.weekday == 1; // Mondays
        case HabitFrequency.monthly:
          return now.day == 1; // First day of month
        case HabitFrequency.weekdays:
          return now.weekday >= 1 && now.weekday <= 5; // Monday to Friday
        case HabitFrequency.weekends:
          return now.weekday == 6 || now.weekday == 7; // Saturday and Sunday
        case HabitFrequency.custom:
          // For custom frequency, implement your own logic
          return true;
        default:
          return false;
      }
    }).toList();
  }

  // CRUD Operations
  Future<void> addHabit(Habit habit, {required String name, required Color color}) async {
    await _storage.addHabit(habit);
    _loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _storage.updateHabit(habit);
    _loadHabits();
  }

  Future<void> deleteHabit(String habitId) async {
    await _storage.deleteHabit(habitId);
    _loadHabits();
  }

  // Habit Completion Operations
  Future<void> toggleHabitCompletion(String habitId) async {
    final today = DateTime.now();
    final habit = _habits.firstWhere((h) => h.id == habitId);
    
    if (habit.isCompletedToday()) {
      await _storage.unmarkHabitCompleted(habitId, today);
    } else {
      await _storage.markHabitCompleted(habitId, today);
    }
    
    _loadHabits();
  }
  
  // Methods for calendar view
  Future<void> markHabitCompletedOnDate(String habitId, DateTime date) async {
    // First make sure we're using midnight of the selected date
    final normalizedDate = DateTime(date.year, date.month, date.day);
    await _storage.markHabitCompleted(habitId, normalizedDate);
    _loadHabits();
  }
  
  Future<void> unmarkHabitCompletedOnDate(String habitId, DateTime date) async {
    // First make sure we're using midnight of the selected date
    final normalizedDate = DateTime(date.year, date.month, date.day);
    await _storage.unmarkHabitCompleted(habitId, normalizedDate);
    _loadHabits();
  }
  
  // Get all habits completed on a specific date
  List<Habit> getHabitsCompletedOnDate(DateTime date) {
    return _habits.where((habit) => 
      habit.completions.any((completion) => 
        completion.date.year == date.year &&
        completion.date.month == date.month &&
        completion.date.day == date.day &&
        completion.completed
      )
    ).toList();
  }
  
  // Get completion stats for analytics
  Map<String, dynamic> getCompletionStats() {
    if (_habits.isEmpty) {
      return {
        'totalCompletions': 0,
        'averageCompletionRate': 0.0,
        'currentStreak': 0,
        'bestStreak': 0,
      };
    }
    
    int totalCompletions = 0;
    for (var habit in _habits) {
      totalCompletions += habit.completions.length;
    }
    
    // Calculate average completion rate for the last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    int possibleCompletions = 0;
    int actualCompletions = 0;
    
    for (var habit in _habits) {
      // Skip habits created less than 30 days ago
      if (habit.createdAt.isAfter(thirtyDaysAgo)) {
        continue;
      }
      
      // Count days this habit should have been completed
      for (var i = 0; i < 30; i++) {
        var day = now.subtract(Duration(days: i));
        // Logic to check if habit should be completed on this day
        // For simplicity, we'll assume all habits are daily
        possibleCompletions++;
        
        // Check if it was actually completed
        if (habit.completions.any((completion) => 
          completion.date.year == day.year &&
          completion.date.month == day.month &&
          completion.date.day == day.day &&
          completion.completed
        )) {
          actualCompletions++;
        }
      }
    }
    
    double averageCompletionRate = possibleCompletions > 0 
      ? actualCompletions / possibleCompletions 
      : 0.0;
    
    // Calculate current streak (simplified)
    int currentStreak = 0;
    int bestStreak = 0;
    
    return {
      'totalCompletions': totalCompletions,
      'averageCompletionRate': averageCompletionRate,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
    };
  }
}