# HitTracker for Android

Native Android port of the HitTracker iOS app for tracking softball hits against opponent teams.

## Features

- **Track Hits**: Tap on the softball field to record hits with type and pitch info
- **Multiple Teams**: Scout multiple opponent teams with separate rosters
- **Results & Stats**: View spray charts, hit type breakdowns, and player statistics
- **Material Design**: Modern Android UI with Jetpack Compose

## Tech Stack

- **Kotlin** - Primary language
- **Jetpack Compose** - Modern declarative UI
- **Room Database** - Local data persistence
- **ViewModel + StateFlow** - Reactive state management
- **Material 3** - Design system

## Requirements

- Android Studio Hedgehog (2023.1.1) or later
- Android SDK 34
- Kotlin 1.9.20+
- Minimum SDK: 26 (Android 8.0)

## Building

1. Open the project in Android Studio
2. Sync Gradle files
3. Run on emulator or device

```bash
./gradlew assembleDebug
```

## Project Structure

```
app/src/main/java/com/cfore/hittracker/
├── data/
│   ├── Models.kt           # Data classes (Team, Player, Hit)
│   ├── Converters.kt       # Room type converters
│   ├── HitTrackerDao.kt    # Database access object
│   ├── HitTrackerDatabase.kt
│   └── HitTrackerRepository.kt
├── ui/
│   ├── theme/              # Material theme
│   ├── components/         # Reusable UI components
│   └── screens/            # App screens
├── viewmodel/
│   └── HitTrackerViewModel.kt
├── HitTrackerApp.kt        # Application class
└── MainActivity.kt         # Main activity
```

## Version

1.0 - Initial Android port
