# Habit App 1

## Overview
A comprehensive habit tracking application built with Flutter, implementing MVVM architecture to help users track and improve their daily habits.

## Features
- Create and manage daily habits
- Track habit completion with visual progress indicators
- Calendar view to monitor habit streaks
- Detailed analytics and progress tracking
- Local data persistence
- Daily habit reminders

## Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Dart SDK

## Initial Setup

1. Clone the repository
```bash
git clone https://github.com/yourusername/habit_tracker.git
cd habit_tracker
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate Hive adapters (if needed)
```bash
flutter pub run build_runner build
```

## Running the App

### For Android
```bash
flutter run
```

### For iOS
```bash
flutter run -d ios
```


### Hive Adapter Generation
If you make changes to the models, regenerate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Development Notes
- The app uses MVVM architecture
- State management is handled with Provider
- Local storage is managed using Hive
- Notifications are implemented with flutter_local_notifications

## Testing
Run unit and widget tests:
```bash
flutter test
```

## Deployment
- For Android: Generate a release APK
  ```bash
  flutter build apk
  ```
- For iOS: Generate an IPA file through Xcode


## Dependencies
- `hive`: Local storage
- `hive_flutter`: Hive Flutter extensions
- `flutter_local_notifications`: Notification service
- `fl_chart`: Data visualization
- `provider`: State management
- `intl`: Date formatting
- `shared_preferences`: Additional local storage

## Project Structure
```
lib/
│
├── models/
│   ├── habit_model.dart
│   └── habit_status_model.dart
│
├── viewmodels/
│   ├── habit_viewmodel.dart
│   └── analytics_viewmodel.dart
│
├── views/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── add_habit_screen.dart
│   │   ├── calendar_view_screen.dart
│   │   └── analytics_screen.dart
│   │
│   └── widgets/
│       ├── habit_tile.dart
│       ├── progress_bar.dart
│       └── calendar_widget.dart
│
├── services/
│   ├── notification_service.dart
│   ├── habit_storage_service.dart
│   └── analytics_service.dart
│
└── utils/
    ├── constants.dart
    └── theme.dart
```

## Testing
```bash
flutter test
```
