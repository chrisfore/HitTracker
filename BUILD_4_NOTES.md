# Build 4 - Development Notes

**Date:** March 3, 2026
**Build:** 1.0 (Build 4)
**Status:** Archived and ready for App Store submission

## Changes Made

### 1. Data Sharing Feature
**Feature:** Coaches can share scouting data with other coaches who use Hit Track Pro.

**Export Options (Settings > Data Management):**
- **Share Player Data** - Select a player, exports their hits + team info
- **Share Team Data** - Exports entire team with all players and hits
- **Share All Data** - Exports everything in the app

**Import Options:**
- **Tap a .hitdata file** - iOS opens it directly in Hit Track Pro (via onOpenURL)
- **Import Shared Data** - Document picker in Settings accepts .hitdata and .json files

**Files Modified:**
- `HitTracker/Models.swift` - Added SharedData struct (Codable wrapper)
- `HitTracker/DatabaseManager.swift` - Added exportPlayerData, exportTeamData, exportAllData, importSharedData methods
- `HitTracker/SettingsView.swift` - Share/import UI, DocumentPicker, UTType.hitdata extension
- `HitTracker/HitTrackerApp.swift` - onOpenURL handler for .hitdata files

### 2. Custom .hitdata File Type
**Feature:** Registered custom UTType so iOS associates .hitdata files with Hit Track Pro.

- **UTI:** `com.cfore.hittracker.hitdata`
- **Extension:** `.hitdata`
- **Conforms to:** `public.json`, `public.data`
- **LSSupportsOpeningDocumentsInPlace:** false

**Files Created/Modified:**
- `HitTracker/Info.plist` (new) - UTExportedTypeDeclarations, CFBundleDocumentTypes
- `HitTracker.xcodeproj/project.pbxproj` - INFOPLIST_FILE reference, file reference

### 3. Help Documentation Updated
- Added "Sharing & Importing Data" section to in-app HelpView
- Updated HTML help documentation with correct hit types and sharing section

**Files Modified:**
- `HitTracker/HelpView.swift` - New help section
- `HitTrackPro_Help_Documentation.html` - Corrected hit types, added sharing section

### 4. Build Number Incremented
- `HitTracker/AppVersion.swift` - Build "3" → "4"
- `HitTracker.xcodeproj/project.pbxproj` - CURRENT_PROJECT_VERSION 3 → 4

## Technical Details

### Import Behavior
- All imported entities get new UUIDs to prevent conflicts
- Old teamId references in players remapped to new team UUIDs
- Old playerId/teamId references in hits remapped to new UUIDs
- First imported team auto-selected after import

### Share Sheet Pattern
- File writing happens on background thread (DispatchQueue.global)
- Share sheet presented after dispatch back to main thread
- Matches existing PDF export pattern to prevent blank share sheet
- ProgressView spinner shown while preparing

### JSON Format
- ISO 8601 date encoding
- Pretty-printed output
- SharedData wrapper: version, exportType, exportDate, teams, players, hits

## Git Commit
```
Add data sharing feature and update docs - Build 4

Added .hitdata file type support for sharing scouting data between coaches.
Coaches can export player, team, or all data and import via document picker
or by tapping a .hitdata file directly.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## Testing
- Build successful (xcodebuild)
- Custom UTType properly embedded in built Info.plist
- Share sheet presents with .hitdata file
- Document picker accepts .hitdata and .json files

## Archive Information
- **Path:** `~/Desktop/HitTracker/build/HitTrackPro.xcarchive`
- **Date:** March 3, 2026
- **Signing:** Apple Development (Chris Fore)
- **Team:** CROSSFIRE-FORE INC. (Z7AM7M3YT2)

---
**Developer:** CROSSFIRE-FORE INC.
**Assisted by:** Claude Opus 4.6
