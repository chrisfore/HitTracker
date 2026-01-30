# HitTracker Development Status

**Last Updated:** 2026-01-30
**Current Build:** 1.24

## Project Overview
HitTracker is an iOS SwiftUI app for tracking softball hits against opponent teams. Users scout multiple opponents, each with their own player roster.

## Recent Changes (This Session)

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
| `DatabaseManager.swift` | Data persistence |
| `Models.swift` | Data structures |
| `AppVersion.swift` | Version tracking (1.24) |

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
