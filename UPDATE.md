# HitTracker Development Status

**Last Updated:** 2026-01-30
**Current Build:** 1.15

## Project Overview
HitTracker is an iOS SwiftUI app for tracking softball hits against opponent teams. Users scout multiple opponents, each with their own player roster.

## Recent Changes (This Session)

### PDF Export & Date Filter (Build 1.15)
- **Export button** in Results toolbar (share icon)
- **Fixed blank share sheet** - Added delay to ensure PDF is written before showing
- **Loading indicator** - Shows spinner while generating PDF
- **Smart file naming:**
  - Player selected: `PlayerName_2026-01-30_130250.pdf`
  - Team selected: `TeamName_2026-01-30_130250.pdf`
  - All data: `All_Data_2026-01-30_130250.pdf`
  - Timestamp makes each export unique
- **Date range filtering:**
  - Toggle "Filter by Date" to enable
  - Start/End date pickers
  - Filters all displayed statistics
  - Date range shown on exported PDF
- **PDF includes:**
  - Team logo (if available)
  - Report title with generation timestamp
  - Date range (if filtering enabled)
  - Summary statistics (filtered by date)
  - Hit type breakdown with color indicators
  - Pitch breakdown (for individual players)
  - Spray chart visualization (filtered hits only)
  - Color legend
  - Footer with app version
- **Share sheet** allows saving to Files, AirDrop, email, etc.

### Bug Fixes (Build 1.13)
1. **Fixed: Field tap allowed without player selected**
   - Added `allowTap` parameter to SoftballFieldView
   - Field taps now only register when a player is selected
   - Prevents confusing UX where user fills form but nothing saves

2. **Fixed: Stale player selection after deletion**
   - Added `.onChange(of: database.players)` handlers in TrackingView and ResultsView
   - Automatically clears selectedPlayer if the player was deleted

3. **Fixed: Pitch filter not cleared on player change**
   - Added `.onChange(of: selectedPlayer)` to clear filter when switching players
   - Prevents showing irrelevant filter for different players

4. **Fixed: "All Teams" player sorting inconsistent**
   - Players now sorted by team name first, then lineup order
   - Consistent ordering when viewing all teams in Results

5. **Fixed: Stale team selection in ResultsView**
   - Added `.onChange(of: database.opponentTeams)` handler
   - Clears team selection if the team was deleted

6. **Added: Empty state in Results view**
   - Shows helpful message when no teams exist
   - Directs user to Settings to create a team

7. **Removed: Unused function in SettingsView**
   - Cleaned up `deletePlayer(at offsets:, from team:)` that was never called

### Previous Features (Build 1.12)
- Create Players button on Track page when team has no players
- 3-digit limit on all player number inputs

### Earlier Session Changes
- Multi-team architecture (Teams, Players, Hits with UUIDs)
- Field sizing fixed to fit on screen
- iPad tab bar icons fixed
- Removed infield dirt, shrunk base paths
- Removed navigation titles from Results/Settings
- Lineup editing redesigned
- Team picker replaced with full-width Menu

## Key Files

| File | Purpose |
|------|---------|
| `TrackingView.swift` | Main tracking screen, field display, sheets |
| `SettingsView.swift` | Team/player management, lineup editing |
| `ResultsView.swift` | Stats display with filtering |
| `ContentView.swift` | Tab navigation, setup flow |
| `TeamSetupView.swift` | Initial app setup |
| `DatabaseManager.swift` | Data persistence |
| `Models.swift` | Data structures |
| `AppVersion.swift` | Version tracking (1.13) |

## Architecture Notes

### Data Model
- `Team`: id (UUID), name
- `Player`: id (UUID), teamId (UUID), name, number, lineupOrder
- `Hit`: id (UUID), playerId (UUID), teamId (UUID), locationX/Y, hitType, pitchType, pitchLocation

### Key Patterns
- `@EnvironmentObject var database: DatabaseManager` for data access
- `@AppStorage` for persisted settings
- `.onChange` handlers to sync state when data changes
- GeometryReader for responsive layouts

## Testing
- Build target: iOS 17.0+
- Test devices: iPhone 17 Pro, iPad simulators
- Bundle ID: `com.cfore.hittracker`

## Build Commands
```bash
# Build
xcodebuild -project HitTracker.xcodeproj -scheme HitTracker -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Install & Launch
xcrun simctl install "iPhone 17 Pro" /path/to/HitTracker.app
xcrun simctl launch "iPhone 17 Pro" com.cfore.hittracker
```

## Plan File Location
Full implementation plan: `~/.claude/plans/witty-sniffing-hejlsberg.md`
