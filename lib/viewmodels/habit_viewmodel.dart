import 'package:flutter/material.dart';
import 'package:habit_app1/services/storage_service.dart';
import '../models/habit_model.dart';

class HabitViewModel extends ChangeNotifier {
  final HabitStorageService _storageService;
  List<Habit> _habits = [];

  HabitViewModel({HabitStorageService? storageService})
      : _storageService = storageService ?? HabitStorageService() {
    _loadHabits();
  }

  List<Habit> get habits => _habits;

  Future<void> _loadHabits() async {
    await _storageService.init();
    _habits = _storageService.getAllHabits();
    notifyListeners();
  }

  Future<void> addHabit({
    required String name,
    Color color = Colors.blue,
    HabitFrequency frequency = HabitFrequency.daily,
    List<int> selectedDays = const [],
  }) async {
    final newHabit = Habit(
      id: '',
      name: name,
      color: color,
      frequency: frequency,
      selectedDays: selectedDays,
    );

    await _storageService.addHabit(newHabit);
    await _loadHabits();
  }

  Future<void> updateHabit(Habit habit) async {
    await _storageService.updateHabit(habit);
    await _loadHabits();
  }

  Future<void> deleteHabit(String habitId) async {
    await _storageService.deleteHabit(habitId);
    await _loadHabits();
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    final habit = _storageService.getHabitById(habitId);
    if (habit != null) {
      final today = DateTime.now();
      if (habit.isCompletedToday()) {
        await _storageService.unmarkHabitCompleted(habitId, today);
      } else {
        await _storageService.markHabitCompleted(habitId, today);
      }
      await _loadHabits();
    }
  }

  List<Habit> getTodayHabits() {
    return _habits.where((habit) => habit.shouldTrackToday()).toList();
  }

  void dispose() {
    _storageService.close();
    super.dispose();
  }
}