import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../models/habit_model.dart';
import 'HabitScreen.dart';
import 'CalendarScreen.dart';
import 'AnalyticsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitModal(context),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHabitList();
      case 1:
        return const CalendarViewScreen();
      case 2:
        return const AnalyticsScreen();
      default:
        return _buildHabitList();
    }
  }

  Widget _buildHabitList() {
    return Consumer<HabitViewModel>(
      builder: (context, viewModel, child) {
        // Use getAllHabits instead of getTodayHabits to show all habits
        final allHabits = viewModel.habits;

        if (allHabits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.checklist_outlined, 
                  size: 100, 
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'No habits to track yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showAddHabitModal(context),
                  child: const Text('Add Your First Habit'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: allHabits.length,
          itemBuilder: (context, index) {
            final habit = allHabits[index];
            return _buildHabitTile(context, habit, viewModel);
          },
        );
      },
    );
  }


  Widget _buildHabitTile(BuildContext context, Habit habit, HabitViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.check_circle,
          color: habit.isCompletedToday() ? habit.color : Colors.grey,
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: habit.isCompletedToday() 
              ? TextDecoration.lineThrough 
              : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.frequency.toString()),
            LinearProgressIndicator(
              value: habit.getWeeklyProgress(),
              backgroundColor: habit.color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(habit.color),
            ),
          ],
        ),
        trailing: Checkbox(
          value: habit.isCompletedToday(),
          onChanged: (_) => viewModel.toggleHabitCompletion(habit.id),
          activeColor: habit.color,
        ),
        onLongPress: () => _showHabitOptions(context, habit, viewModel),
      ),
    );
  }

  void _showHabitOptions(BuildContext context, Habit habit, HabitViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Habit'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddHabitModal(context, habit: habit);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Habit', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteHabit(context, habit, viewModel);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteHabit(BuildContext context, Habit habit, HabitViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text('Are you sure you want to delete "${habit.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.deleteHabit(habit.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddHabitModal(BuildContext context, {Habit? habit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddHabitScreen(existingHabit: habit),
    );
  }


  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Habits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: 'Analytics',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showAddHabitModal(context),
      child: const Icon(Icons.add),
    );
  }
}