import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_app1/models/habit_model.dart';
import './color_adapter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  
  // Register the ColorAdapter
  Hive.registerAdapter(ColorAdapter());
  
  // Register your existing adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());
  Hive.registerAdapter(HabitCompletionAdapter());
}

// Fixing existing boxes that might contain corrupt data
Future<void> fixHabitBox() async {
  // Only run this code once to fix existing boxes
  try {
    final box = await Hive.openBox<dynamic>('habits_raw');
    
    // Get all keys in the box
    final keys = box.keys.toList();
    
    // Create a new, fixed box
    final fixedBox = await Hive.openBox<Habit>('habits');
    
    // Clear the fixed box to avoid duplicates
    await fixedBox.clear();
    
    // Process and fix each entry
    for (var key in keys) {
      try {
        final Map<dynamic, dynamic> rawData = box.get(key);
        
        // Extract and fix each field
        String id = rawData[0] as String;
        String name = rawData[1] as String;
        
        // Fix the color field
        Color color;
        try {
          dynamic colorValue = rawData[2];
          color = Habit.intToColor(colorValue);
        } catch (e) {
          color = Colors.blue; // Default if conversion fails
        }
        
        // Extract remaining fields
        HabitFrequency frequency = HabitFrequency.values[rawData[3] as int];
        List<int> selectedDays = (rawData[4] as List).cast<int>();
        DateTime createdAt = rawData[5] as DateTime;
        List<HabitCompletion> completions = [];
        
        // Try to convert completions if available
        try {
          completions = (rawData[6] as List)
              .map((data) => HabitCompletion(
                    date: data[0] as DateTime,
                    completed: data[1] as bool,
                  ))
              .toList();
        } catch (e) {
          // If conversion fails, leave completions empty
        }
        
        // Create a fixed Habit object
        final fixedHabit = Habit(
          id: id,
          name: name,
          color: color,
          frequency: frequency,
          selectedDays: selectedDays,
          createdAt: createdAt,
          completions: completions,
        );
        
        // Store in the fixed box
        await fixedBox.put(id, fixedHabit);
      } catch (e) {
        print('Error fixing habit with key $key: $e');
        // Continue with next entry
      }
    }
    
    // Close boxes when done
    await box.close();
    await fixedBox.close();
    
    print('Habit box fixing completed');
  } catch (e) {
    print('Error while fixing habit box: $e');
  }
}