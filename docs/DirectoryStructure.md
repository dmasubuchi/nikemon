# Nike+ Clone App - Directory Structure

The application follows a role-based architecture with the following directory structure:

```
lib/
├── main.dart          # App entry point
├── screens/           # UI screens and pages
│   ├── home_screen.dart
│   ├── workout_screen.dart
│   ├── result_screen.dart
│   └── history_screen.dart
├── services/          # Business logic and data handling
│   ├── gps_service.dart
│   ├── workout_service.dart
│   └── storage_service.dart
├── models/            # Data classes and structures
│   ├── workout_model.dart
│   └── user_profile_model.dart
├── widgets/           # Reusable UI components
│   ├── workout_card.dart
│   ├── stat_display.dart
│   └── custom_buttons.dart
└── utils/             # Helper functions and utilities
    ├── formatters.dart
    └── constants.dart
```

## Role Descriptions

### screens/
Contains the main UI screens of the application. Each screen is responsible for displaying content and handling user interactions, delegating business logic to services.

### services/
Handles business logic, data processing, and interactions with device features like GPS. Services are responsible for the core functionality of the app.

### models/
Defines data structures used throughout the application. Models represent the shape of data and may include serialization/deserialization logic.

### widgets/
Houses reusable UI components that are used across multiple screens. Widgets should be modular and configurable.

### utils/
Contains helper functions, constants, and utility classes that support the application but don't fit into the other categories.
