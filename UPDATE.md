# HitTracker Development Status

**Last Updated:** 2026-02-05
**Current Build:** 1.28 (iOS) / 1.0 (Android)

## Project Overview
HitTracker is an app for tracking softball hits against opponent teams. Users scout multiple opponents, each with their own player roster. Available for both iOS (SwiftUI) and Android (Kotlin/Jetpack Compose).

## Recent Changes (This Session)

### Build 1.28 - iCloud Sync
- **Cross-device sync**: Data now syncs across Apple devices via iCloud
- **NSUbiquitousKeyValueStore**: Teams, players, hits, and logo sync automatically
- **Local fallback**: Data saved locally if iCloud unavailable
- **Migration**: Existing local data migrated to iCloud on upgrade
- **Real-time updates**: App refreshes when data changes from another device

### Android 1.0 - Initial Android Port
- **Native Android app**: Full port to Kotlin + Jetpack Compose
- **Room Database**: Local persistence using Room (equivalent to iOS Core Data)
- **Material 3 UI**: Modern Android design system
- **Feature parity**: Track, Results, and Settings screens ported
- **Branch**: `android` branch on GitHub
- **Build fixes**: Updated AGP 8.2.2, Kotlin 1.9.21, KSP 1.9.21-1.0.15
- **Launcher icon**: Adaptive icon with HT logo

### Build 1.27 - App Icon
- **Custom app icon**: Added HT Logo as the app icon

### Build 1.26 - Results Page Layout
- **Spray chart repositioned**: Now appears above "Hits by Player" when viewing team overview

### Build 1.25 - Production Bug Scrub
- **Removed dead code**: Cleaned up unused InfieldShape from TrackingView
- **Removed placeholder feature**: Removed non-functional "Restore Purchases" button from setup
- **Fixed redundant save**: Logo no longer saved twice during setup
- **Date validation**: End date automatically adjusts if set before start date in Results

### Build 1.24 - App Store Release
- **Settings cleanup**: Simplified "Change Team Name" button (removed redundant team name display)

### Build 1.23 - Results Spray Chart Improvements
- **Base paths & bases**: Spray charts now include base paths and base markers (matching Track page)
- **Reordered player stats**: Spray chart shown first, then hit types and pitch breakdown below
- **PDF export updated**: Player stats PDF also shows spray chart first

### Build 1.19 - Results Page Improvements
- **Reordered sections**: "Hits by Player" now appears before "Team Summary"
- **Tappable player rows**: Tap any player in the list to view their detailed stats
- **Chevron indicators** show rows are interactive

### Build 1.18 - Track Page Team View
- **Combined team hits**: When no player selected, shows all hits from selected team
- **Hit input protection**: Field taps only allowed when both team AND player selected

### Build 1.17 - UI Cleanup
- Removed "Summary - #2" heading from player stats
- "Total Hits" now part of "Hit Types" section

### Build 1.16 - Export Button Redesign
- Export button moved into list format (matches "Filter by Date" style)
- Removed toolbar export button

### Build 1.15 - PDF Export & Date Filter
- **Fixed blank share sheet**: Added delay to ensure PDF is written
- **Loading indicator**: Shows spinner while generating PDF
- **Smart file naming**: `PlayerName_2026-01-30_130250.pdf` or `TeamName_...` or `All_Data_...`
- **Date range filtering**: Toggle to filter hits by date range
- **Date range in exports**: PDF shows filtered date range

### Build 1.13 - Bug Fixes
- Fixed field tap allowed without player selected
- Fixed stale player selection after deletion
- Fixed pitch filter not clearing on player change
- Fixed "All Teams" player sorting inconsistent
- Added empty state in Results view
- Removed unused function in SettingsView

### Build 1.12 - Player Creation
- "Create Players" button on Track page when team has no players
- 3-digit limit on all player number inputs

## Key Files

| File | Purpose |
|------|---------|
| `TrackingView.swift` | Main tracking screen, field display, hit input |
| `ResultsView.swift` | Stats display, PDF export, date filtering |
| `SettingsView.swift` | Team/player management, lineup editing |
| `ContentView.swift` | Tab navigation, setup flow |
| `TeamSetupView.swift` | Initial app setup |
| `DatabaseManager.swift` | Data persistence, iCloud sync |
| `Models.swift` | Data structures |
| `AppVersion.swift` | Version tracking (1.28) |

## Features

### Track Page
- Team selector in toolbar
- Player dropdown (shows "Create Players" if none exist)
- Softball field with hit visualization
- Combined team hits when no player selected
- Pitch stats bar (tappable to filter hits)
- Hit type legend
- Landscape/portrait adaptive layouts

### Results Page
- Date range filtering (toggle + date pickers)
- PDF export with team logo
- Team/player filter dropdowns
- Tappable player list to view individual stats
- Hit type breakdown with colors
- Pitch breakdown
- Spray chart visualization

### Settings Page
- Team management (create, rename, delete)
- Player management (add, reorder, delete)
- Lineup editing with drag handles
- Clear player/all hit data
- Team logo upload
- Dark mode toggle
- Help documentation

## Architecture

### Data Model
- `Team`: id (UUID), name
- `Player`: id (UUID), teamId, name, number, lineupOrder
- `Hit`: id (UUID), playerId, teamId, locationX/Y, hitType, pitchType, pitchLocation, timestamp

### Key Patterns
- `@EnvironmentObject var database: DatabaseManager`
- `@AppStorage` for persisted settings
- `NSUbiquitousKeyValueStore` for iCloud sync
- `.onChange` handlers for state synchronization
- GeometryReader for responsive layouts
- Background thread PDF generation

## Build & Test

```bash
# Build
xcodebuild -project HitTracker.xcodeproj -scheme HitTracker -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Install & Launch
xcrun simctl install "iPhone 17 Pro" /path/to/HitTracker.app
xcrun simctl launch "iPhone 17 Pro" com.cfore.hittracker
```

- **Target**: iOS 17.0+
- **Bundle ID**: `com.cfore.hittracker`
- **Test devices**: iPhone 17 Pro, iPad simulators

## Android Version

The Android port lives on the `android` branch and in the `HitTracker-Android` folder on Desktop.

### Tech Stack
- **Kotlin 1.9.21** + **Jetpack Compose** for UI
- **Room Database** for persistence
- **ViewModel + StateFlow** for state management
- **Material 3** design system
- **Android Gradle Plugin**: 8.2.2

### Android Key Files

| File | Purpose |
|------|---------|
| `TrackingScreen.kt` | Main tracking screen, field display, hit input |
| `ResultsScreen.kt` | Stats display, spray charts |
| `SettingsScreen.kt` | Team/player management |
| `MainScreen.kt` | Tab navigation, setup flow |
| `TeamSetupScreen.kt` | Initial app setup |
| `HitTrackerRepository.kt` | Data persistence |
| `Models.kt` | Data structures (Room entities) |
| `HitTrackerViewModel.kt` | State management |

### Build Android

```bash
# Build
cd HitTracker-Android
./gradlew assembleDebug

# Or open in Android Studio and run
```

- **Min SDK**: 26 (Android 8.0)
- **Target SDK**: 34
- **Package**: `com.cfore.hittracker`
