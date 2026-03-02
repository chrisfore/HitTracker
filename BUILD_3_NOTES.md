# Build 3 - Development Notes

**Date:** March 2, 2026
**Build:** 1.0 (Build 3)
**Status:** Archived and ready for App Store submission

## Changes Made

### 1. iPad UI Improvements
**Problem:** Hit input sheet on iPad had layout issues
- Pitch location selector box too small, required scrolling
- Buttons not visible or wrapping incorrectly
- Poor use of screen space

**Solution:** Redesigned with FlowLayout
- Created custom `FlowLayout` (SwiftUI Layout protocol)
- Replaced horizontal ScrollView with adaptive wrapping layout
- Removed Form wrapper, used VStack + ScrollView
- All buttons now visible without scrolling
- Works in both portrait and landscape orientations

**Files Modified:**
- `HitTracker/TrackingView.swift` (lines 765-873)
  - Added FlowLayout struct (custom Layout protocol)
  - Redesigned HitInputSheet with ScrollView + VStack
  - FlowLayout for Pitch Type and Pitch Location sections

### 2. Spray Chart Size Increase
**Problem:** Spray charts too small, hard to read on iPad

**Solution:** Doubled chart size
- Changed from 200×200 to 400×400 pixels
- Applied to both individual player stats and team overview

**Files Modified:**
- `HitTracker/ResultsView.swift`
  - Line 665: PlayerStatsSection spray chart
  - Line 757: TeamOverviewSection spray chart

### 3. Text Size Controls
**Problem:** No way for users to adjust text size throughout app

**Solution:** Added text size picker in Settings
- Options: System, Small, Medium, Large, Extra Large
- Saved with @AppStorage for persistence
- Applied app-wide via ContentView

**Files Modified:**
- `HitTracker/SettingsView.swift`
  - Line 7: Added @AppStorage for textSizePreference
  - Lines 193-207: Added text size picker in Appearance section
- `HitTracker/ContentView.swift`
  - Line 8: Added @AppStorage for textSizePreference
  - Line 35: Applied `.dynamicTypeSize(textSize)` modifier
  - Lines 38-49: Added computed property for text size mapping

### 4. iPad Screenshots
**Added:** 4 iPad screenshots in portrait orientation
- Resolution: 2064×2752 pixels (App Store requirement)
- Rotated from landscape simulator output
- Location: `Screenshots/ipad/`

## Technical Details

### FlowLayout Implementation
Custom Layout protocol that:
- Calculates row arrangements based on available width
- Wraps buttons to multiple rows automatically
- Adapts to screen size and orientation
- No fixed row structure

### Text Size System
- Uses SwiftUI's DynamicTypeSize enum
- Applied at ContentView root level
- Cascades to all child views
- System option allows device accessibility settings

### Build Process
1. Increment: `./increment-build.sh` → Build 3
2. Update: `update.md` with changelog
3. Clean: `xcodebuild clean -scheme HitTracker`
4. Archive: Generated for App Store submission
5. Location: `~/Desktop/HitTracker/build/HitTrackPro.xcarchive`

## Git Commit
```
Improve iPad UI and add text size controls - Build 3

- Redesign hit input sheet with FlowLayout for better button wrapping on iPad
- Double spray chart size from 200x200 to 400x400 for improved readability
- Add text size controls in Settings (System/Small/Medium/Large/Extra Large)
- Add iPad screenshots (2064×2752px portrait orientation)
- Update context document with Build 3 changes

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```

## Testing
- ✅ App builds successfully
- ✅ Launches on iPad Pro 13-inch (M5) simulator
- ✅ No crashes or errors in logs
- ✅ Hit input sheet displays all options without scrolling
- ✅ Spray charts render at 400×400
- ✅ Text size controls functional in Settings

## Next Steps
1. Open archive in Xcode Organizer
2. Click "Distribute App" → "App Store Connect"
3. Upload Build 3 to TestFlight
4. Submit for App Store review

## Archive Information
- **Path:** `~/Desktop/HitTracker/build/HitTrackPro.xcarchive`
- **Date:** March 2, 2026
- **Signing:** Apple Development (Chris Fore)
- **Team:** CROSSFIRE-FORE INC. (Z7AM7M3YT2)
- **Provisioning:** iOS Team Provisioning Profile

---
**Developer:** CROSSFIRE-FORE INC.
**Assisted by:** Claude Opus 4.6
