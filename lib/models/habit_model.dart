import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class Habit {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Color color;

  @HiveField(3)
  HabitFrequency frequency;

  @HiveField(4)
  List<int> selectedDays; // For specific day frequency

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  List<HabitCompletion> completions;

  Habit({
    required this.id,
    required this.name,
    this.color = Colors.blue,
    this.frequency = HabitFrequency.daily,
    this.selectedDays = const [],
    DateTime? createdAt,
    List<HabitCompletion>? completions,
  })  : createdAt = createdAt ?? DateTime.now(),
        completions = completions ?? [];

  bool isCompletedToday() {
    final today = DateTime.now();
    return completions.any((completion) => 
      completion.date.year == today.year &&
      completion.date.month == today.month &&
      completion.date.day == today.day
    );
  }

  double getWeeklyProgress() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weekCompletions = completions.where((completion) => 
      completion.date.isAfter(weekAgo) && completion.date.isBefore(now.add(const Duration(days: 1)))
    ).length;

    return weekCompletions / 7.0;
  }

  bool shouldTrackToday() {
    final today = DateTime.now();
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekdays:
        return today.weekday < 6; // Monday to Friday
      case HabitFrequency.specific:
        return selectedDays.contains(today.weekday);
      case HabitFrequency.weekly:
        // TODO: Handle this case.
        throw UnimplementedError();
      case HabitFrequency.monthly:
        // TODO: Handle this case.
        throw UnimplementedError();
      case HabitFrequency.weekends:
        // TODO: Handle this case.
        throw UnimplementedError();
      case HabitFrequency.custom:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // Add a method to handle integer to Color conversion for backward compatibility
  static Color intToColor(dynamic colorValue) {
    if (colorValue is Color) {
      return colorValue;
    } else if (colorValue is int) {
      return Color(colorValue);
    }
    // Default color if conversion fails
    return Colors.blue;
  }
}

@HiveType(typeId: 1)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekdays,
  @HiveField(2)
  specific, weekly, monthly, weekends, custom
}

@HiveType(typeId: 2)
class HabitCompletion {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool completed;

  HabitCompletion({
    required this.date,
    this.completed = true,
  });
}