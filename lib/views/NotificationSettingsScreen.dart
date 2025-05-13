import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _areNotificationsEnabled = false;
  TimeOfDay _selectedReminderTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _areNotificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      
      // Load saved time or use current time
      final savedHour = prefs.getInt('reminder_hour') ?? TimeOfDay.now().hour;
      final savedMinute = prefs.getInt('reminder_minute') ?? TimeOfDay.now().minute;
      _selectedReminderTime = TimeOfDay(hour: savedHour, minute: savedMinute);
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('notifications_enabled', _areNotificationsEnabled);
    await prefs.setInt('reminder_hour', _selectedReminderTime.hour);
    await prefs.setInt('reminder_minute', _selectedReminderTime.minute);

    // Manage notifications based on setting
    if (_areNotificationsEnabled) {
      await _scheduleNotification();
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  Future<void> _scheduleNotification() async {
    // Initialize notification service
    await _notificationService.init();

    // Schedule daily reminder
    await _notificationService.scheduleHabitReminder(
      id: 0, // Unique ID for the notification
      title: 'Time to Track Your Habits!',
      body: 'Check off your daily habits and stay consistent.',
      notificationTime: TimeOfDay(
        hour: _selectedReminderTime.hour, 
        minute: _selectedReminderTime.minute
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedReminderTime) {
      setState(() {
        _selectedReminderTime = pickedTime;
      });
      await _saveNotificationSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Habit Reminders'),
            subtitle: const Text('Get daily reminders to track your habits'),
            value: _areNotificationsEnabled,
            onChanged: (bool value) async {
              setState(() {
                _areNotificationsEnabled = value;
              });
              await _saveNotificationSettings();
            },
          ),
          if (_areNotificationsEnabled)
            ListTile(
              title: const Text('Reminder Time'),
              subtitle: Text(
                _selectedReminderTime.format(context),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _selectReminderTime,
            ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Choose a time that works best for your daily routine.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}              