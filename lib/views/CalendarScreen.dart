import 'package:flutter/material.dart';
import 'package:habit_app1/models/habit_model.dart';
import 'package:provider/provider.dart';
import '../viewmodels/habit_viewmodel.dart';

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
            _buildWeekdayHeaders(),
            Expanded(child: _buildCalendarGrid(viewModel.habits)),
            _buildHabitLegend(viewModel.habits),
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
                  _selectedMonth.month - 1,
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
                  _selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final List<String> weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(List<Habit> habits) {
    final daysInMonth = _getDaysInMonth(_selectedMonth);
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );

    // Calculate start padding based on weekday (1-7, where 1 is Monday)
    // Convert to 0-based for grid (0 = Monday, 6 = Sunday)
    int startPadding = firstDayOfMonth.weekday - 1;

    // Calculate the total number of cells we need in the grid
    int totalCells = startPadding + daysInMonth;

    // Make sure we have a complete last week
    int endPadding = (7 - (totalCells % 7)) % 7;
    totalCells += endPadding;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startPadding || index >= startPadding + daysInMonth) {
          // Empty cells before first day or after last day
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }

        final dayNumber = index - startPadding + 1;
        final currentDate = DateTime(
          _selectedMonth.year,
          _selectedMonth.month,
          dayNumber,
        );

        // Check if this is today
        final isToday = _isToday(currentDate);

        return _buildCalendarDay(currentDate, habits, isToday);
      },
    );
  }

  Widget _buildCalendarDay(DateTime date, List<Habit> habits, bool isToday) {
    // Check completions for all habits on this date
    final completedHabits =
        habits
            .where(
              (habit) => habit.completions.any(
                (completion) =>
                    completion.date.year == date.year &&
                    completion.date.month == date.month &&
                    completion.date.day == date.day &&
                    completion.completed,
              ),
            )
            .toList();

    // Calculate completion percentage
    double completionPercentage =
        habits.isEmpty ? 0 : completedHabits.length / habits.length;

    // Determine colors based on completion
    Color backgroundColor = Colors.grey.withOpacity(0.1);
    if (completedHabits.isNotEmpty) {
      if (completionPercentage >= 1) {
        backgroundColor = Colors.green.withOpacity(0.3);
      } else {
        backgroundColor = Colors.orange.withOpacity(0.2);
      }
    }

    return InkWell(
      onTap: () => _showDayDetails(date, habits, completedHabits),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border:
              isToday
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (completedHabits.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${completedHabits.length}/${habits.length}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    completionPercentage >= 1
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 10,
                    color:
                        completionPercentage >= 1
                            ? Colors.green
                            : Colors.orange,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDayDetails(
    DateTime date,
    List<Habit> allHabits,
    List<Habit> completedHabits,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<HabitViewModel>(
          builder: (context, viewModel, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_formatDayMonth(date)} - ${_formatWeekday(date)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Habits for this day:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allHabits.length,
                      itemBuilder: (context, index) {
                        final habit = allHabits[index];
                        final isCompleted = completedHabits.contains(habit);

                        return ListTile(
                          leading: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isCompleted ? habit.color : Colors.grey,
                          ),
                          title: Text(habit.name),
                          trailing: IconButton(
                            icon: Icon(isCompleted ? Icons.undo : Icons.check),
                            onPressed: () {
                              if (isCompleted) {
                                viewModel.unmarkHabitCompletedOnDate(
                                  habit.id,
                                  date,
                                );
                              } else {
                                viewModel.markHabitCompletedOnDate(
                                  habit.id,
                                  date,
                                );
                              }
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHabitLegend(List<Habit> habits) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildLegendItem(
              Colors.green.withOpacity(0.3),
              'All habits completed',
            ),
          ),
          Expanded(
            child: _buildLegendItem(
              Colors.orange.withOpacity(0.2),
              'Some habits completed',
            ),
          ),
          Expanded(
            child: _buildLegendItem(
              Colors.grey.withOpacity(0.1),
              'No habits completed',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Ensure the Row takes minimal width
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Flexible( // Allows the text to wrap if needed
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis, // Handle potential long text
          ),
        ),
      ],
    );
  }

  String _formatMonthYear(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  String _formatDayMonth(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _formatWeekday(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[date.weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}