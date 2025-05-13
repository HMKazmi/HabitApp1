import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit_model.dart';
import '../viewmodels/habit_viewmodel.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit? existingHabit;

  const AddHabitScreen({Key? key, this.existingHabit}) : super(key: key);

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  late TextEditingController _nameController;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  Color _selectedColor = Colors.blue;
  List<int> _selectedDays = [];

  // Color palette for habit selection
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
  ];

  // Day names for specific day selection
  final List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing habit data if editing
    _nameController = TextEditingController(
      text: widget.existingHabit?.name ?? '',
    );
    
    if (widget.existingHabit != null) {
      _selectedFrequency = widget.existingHabit!.frequency;
      _selectedColor = widget.existingHabit!.color;
      _selectedDays = widget.existingHabit!.selectedDays;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    final viewModel = Provider.of<HabitViewModel>(context, listen: false);

    if (widget.existingHabit != null) {
      // Update existing habit
      final updatedHabit = Habit(
        id: widget.existingHabit!.id,
        name: _nameController.text.trim(),
        color: _selectedColor,
        frequency: _selectedFrequency,
        selectedDays: _selectedFrequency == HabitFrequency.specific 
          ? _selectedDays 
          : [],
        createdAt: widget.existingHabit!.createdAt,
        completions: widget.existingHabit!.completions,
      );
      viewModel.updateHabit(updatedHabit);
    } else {
      // Add new habit
      viewModel.addHabit(
        name: _nameController.text.trim(),
        color: _selectedColor,
        frequency: _selectedFrequency,
        selectedDays: _selectedFrequency == HabitFrequency.specific 
          ? _selectedDays 
          : [],
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingHabit != null ? 'Edit Habit' : 'Add New Habit',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Habit Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Frequency Selection
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _buildFrequencyOptions(),
            const SizedBox(height: 16),

            // Color Selection
            Text(
              'Choose Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _buildColorOptions(),
            const SizedBox(height: 16),

            // Specific Days Selection (if applicable)
            if (_selectedFrequency == HabitFrequency.specific)
              _buildDaySelection(),

            // Save Button
            ElevatedButton(
              onPressed: _saveHabit,
              child: Text(widget.existingHabit != null ? 'Update Habit' : 'Create Habit'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOptions() {
    return Wrap(
      spacing: 8,
      children: HabitFrequency.values.map((frequency) {
        return ChoiceChip(
          label: Text(_getFrequencyLabel(frequency)),
          selected: _selectedFrequency == frequency,
          onSelected: (bool selected) {
            setState(() {
              _selectedFrequency = frequency;
              // Reset selected days when changing frequency
              _selectedDays.clear();
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildColorOptions() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _colorOptions.map((color) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = color;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: _selectedColor == color
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Specific Days',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Wrap(
          spacing: 8,
          children: List.generate(_dayNames.length, (index) {
            final dayIndex = index + 1; // Convert to 1-7 index
            return FilterChip(
              label: Text(_dayNames[index]),
              selected: _selectedDays.contains(dayIndex),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayIndex);
                  } else {
                    _selectedDays.remove(dayIndex);
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  String _getFrequencyLabel(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekdays:
        return 'Weekdays';
      case HabitFrequency.specific:
        return 'Specific Days';
    }
  }
} 