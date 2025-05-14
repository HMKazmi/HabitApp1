import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';

class HabitStorageService {
  static const String _habitsBoxName = 'habits_box';
  late Box<Habit> _habitsBox;
  static bool _adaptersRegistered = false;

  Future<void> init() async {
    // Skip the initialization of Hive and adapter registration
    // since it's already done in main.dart
    
    // Only register adapters if they haven't been registered already
    if (!_adaptersRegistered) {
      try {
        // Register adapters
        Hive.registerAdapter(HabitAdapter());
        Hive.registerAdapter(HabitFrequencyAdapter());
        Hive.registerAdapter(HabitCompletionAdapter());
        _adaptersRegistered = true;
      } catch (e) {
        // Adapters are already registered, that's fine
        print('Adapters already registered: $e');
        _adaptersRegistered = true;
      }
    }

    // Just open the box
    _habitsBox = await Hive.openBox<Habit>(_habitsBoxName);
  }

  List<Habit> getAllHabits() {
    return _habitsBox.values.toList();
  }

  Habit? getHabitById(String id) {
    return _habitsBox.values.firstWhere((habit) => habit.id == id);
  }

  Future<void> addHabit(Habit habit) async {
    // Generate a unique ID if not provided
    habit.id = habit.id.isEmpty ? const Uuid().v4() : habit.id;
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitsBox.delete(habitId);
  }

  Future<void> markHabitCompleted(String habitId, DateTime date) async {
    final habit = getHabitById(habitId);
    if (habit != null) {
      habit.completions.add(HabitCompletion(
        date: date,
        completed: true,
      ));
      await updateHabit(habit);
    }
  }

  Future<void> unmarkHabitCompleted(String habitId, DateTime date) async {
    final habit = getHabitById(habitId);
    if (habit != null) {
      habit.completions.removeWhere((completion) => 
        completion.date.year == date.year &&
        completion.date.month == date.month &&
        completion.date.day == date.day
      );
      await updateHabit(habit);
    }
  }

  Future<void> close() async {
    await _habitsBox.close();
  }
}