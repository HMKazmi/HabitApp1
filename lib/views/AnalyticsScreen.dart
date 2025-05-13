import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/habit_viewmodel.dart';
import '../../models/habit_model.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitViewModel>(
      builder: (context, viewModel, child) {
        final habits = viewModel.habits;

        if (habits.isEmpty) {
          return const Center(child: Text('No habits to show analytics'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOverallProgressCard(habits),
                const SizedBox(height: 16),
                _buildHabitProgressChart(habits),
                const SizedBox(height: 16),
                _buildHabitStreaksSection(habits),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverallProgressCard(List<Habit> habits) {
    final totalHabits = habits.length;
    final completedHabits =
        habits.where((habit) => habit.isCompletedToday()).length;
    final completionPercentage =
        totalHabits > 0
            ? (completedHabits / totalHabits * 100).toStringAsFixed(1)
            : '0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '$completedHabits/$totalHabits',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Habits Completed Today'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$completionPercentage%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Completion Rate'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitProgressChart(List<Habit> habits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Habit Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups:
                      habits.map((habit) {
                        final progress = habit.getWeeklyProgress();
                        return BarChartGroupData(
                          x: habits.indexOf(habit),
                          barRods: [
                            BarChartRodData(
                              toY: progress * 100,
                              color: habit.color,
                              width: 16,
                            ),
                          ],
                        );
                      }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              habits[index].name,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStreaksSection(List<Habit> habits) {
    // Calculate streak for each habit
    final habitStreaks =
        habits.map((habit) {
          // This is a simplified streak calculation
          int streak = 0;
          final sortedCompletions =
              habit.completions.toList()
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

    // Return a placeholder widget for now
    return const Center(child: Text('Habit streaks will be displayed here.'));
  }

  bool _isConsecutiveDay(DateTime currentDate, DateTime previousDate) {
    return currentDate.difference(previousDate).inDays == 1;
  }
}
