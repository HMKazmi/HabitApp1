import 'package:flutter/material.dart';
import 'package:habit_app1/models/habit_model.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/habit_viewmodel.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({Key? key}) : super(key: key);

  @override
  _CalendarViewScreenState createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            _buildMonthHeader(),
            Expanded(
              child: _buildCalendarGrid(viewModel.habits),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year, 
                  _selectedMonth.month - 1
                );
              });
            },
          ),
          Text(
            _formatMonthYear(_selectedMonth),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(
                  _selectedMonth.year, 
                  _selectedMonth.month + 1
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<Habit> habits) {
    final daysInMonth = _getDaysInMonth(_selectedMonth);
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: daysInMonth + startingWeekday - 1,
      itemBuilder: (context, index) {
        if (index < startingWeekday - 1) {
          return Container(); // Empty cell before first day
        }

        final dayNumber = index - startingWeekday + 2;
        final currentDate = DateTime(
          _selectedMonth.year, 
          _selectedMonth.month, 
          dayNumber
        );

        return _buildCalendarDay(currentDate, habits);
      },
    );
  }

  Widget _buildCalendarDay(DateTime date, List<Habit> habits) {
    // Check completions for all habits on this date
    final completedHabits = habits.where((habit) => 
      habit.completions.any((completion) => 
        completion.date.year == date.year &&
        completion.date.month == date.month &&
        completion.date.day == date.day
      )
    ).toList();

    return Container(
      decoration: BoxDecoration(
        color: completedHabits.isNotEmpty 
          ? Colors.green.withOpacity(0.2) 
          : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (completedHabits.isNotEmpty)
              Icon(
                Icons.check_circle_outline,
                size: 12,
                color: completedHabits.first.color,
              ),
          ],
        ),
      ),
    );
  }

  String _formatMonthYear(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 
      'May', 'June', 'July', 'August', 
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }
}