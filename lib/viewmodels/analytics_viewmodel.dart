import 'package:flutter/foundation.dart';
import 'package:habit_app1/services/storage_service.dart';
import '../models/habit_model.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final HabitStorageService _storageService;
  List<Habit> _habits = [];

  AnalyticsViewModel({HabitStorageService? storageService})
      : _storageService = storageService ?? HabitStorageService() {
    _loadHabits();
  }

  List<Habit> get habits => _habits;

  Future<void> _loadHabits() async {
    await _storageService.init();
    _habits = _storageService.getAllHabits();
    notifyListeners();
  }

  // Calculates overall completion rate
  double getOverallCompletionRate() {
    if (_habits.isEmpty) return 0.0;

    final totalHabits = _habits.length;
    final completedHabits = _habits.where((habit) => habit.isCompletedToday()).length;
    
    return completedHabits / totalHabits;
  }

  // Calculates weekly completion rate for a specific habit
  double getWeeklyCompletionRate(Habit habit) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weekCompletions = habit.completions.where((completion) => 
      completion.date.isAfter(weekAgo) && 
      completion.date.isBefore(now.add(const Duration(days: 1)))
    ).length;

    return weekCompletions / 7.0;
  }

  // Get top streaks for habits
  List<MapEntry<Habit, int>> getHabitStreaks() {
    final habitStreaks = _habits.map((habit) {
      int streak = 0;
      final sortedCompletions = habit.completions.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      DateTime? previousDate;
      for (var completion in sortedCompletions) {
        if (previousDate == null || 
            _isConsecutiveDay(completion.date, previousDate)) {
          streak++;
          previousDate = completion.date;
        } else {
          break;
        }
      }
      
      return MapEntry(habit, streak);
    }).toList();

    // Sort streaks in descending order
    habitStreaks.sort((a, b) => b.value.compareTo(a.value));
    return habitStreaks;
  }

  // Check if two dates are consecutive
  bool _isConsecutiveDay(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2);
    return difference.inDays.abs() == 1;
  }

  // Get habits with most/least completions
  List<MapEntry<Habit, int>> getHabitCompletionCounts() {
    final habitCompletions = _habits.map((habit) {
      final completionCount = habit.completions.length;
      return MapEntry(habit, completionCount);
    }).toList();

    // Sort by completion count in descending order
    habitCompletions.sort((a, b) => b.value.compareTo(a.value));
    return habitCompletions;
  }
} 