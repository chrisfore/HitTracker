# Hit Track Pro - Claude Context Document

## Overview
Hit Track Pro is a universal SwiftUI iOS app for tracking softball/baseball hits against opponent teams. Coaches scout multiple opponents, each with their own player roster. Runs natively on iPhone and iPad with full feature parity and cross-device data sync.

## App Details
- **App Name:** Hit Track Pro (App Store display name)
- **Bundle ID:** `com.cfore.hittracker`
- **Current Version:** 1.0 (fixed) - Build 3
- **Deployment Target:** iOS 17.0
- **Supported Devices:** iPhone and iPad (Universal App)
- **Swift Version:** 5.0
- **Development Team:** Z7AM7M3YT2 (CROSSFIRE-FORE INC.)
- **Repository:** https://github.com/chrisfore/HitTracker.git (public - docs only)
- **App Store Status:** Ready for submission - Build 3

### Versioning Strategy
- **Marketing Version:** 1.0 (stays fixed for all updates)
- **Build Number:** Increments with each App Store upload (1, 2, 3...)
- To increment build: `./increment-build.sh` (updates both AppVersion.swift and project.pbxproj)

### Privacy & Legal
- **Privacy Policy:** https://chrisfore.github.io/HitTracker/privacy-policy.html
- **Support URL:** https://chrisfore.github.io/HitTracker/
- **Copyright:** 2026 CROSSFIRE-FORE INC.

## Key Features
1. **Hit Tracking** - Tap softball field to record hit location, type, and pitch details
2. **Multiple Teams** - Track multiple opponent teams, each with their own roster
3. **Live Stats** - Spray charts, hit type breakdown, pitch location analysis
4. **PDF Export** - Professional reports with team logo and date filtering
5. **iCloud Sync** - Automatic sync across all Apple devices
6. **Dark Mode** - Support for light and dark themes
7. **Adjustable Text Size** - Control text size app-wide from Settings

## Recent Changes (Build 3)
- **Improved iPad UI:** Redesigned hit input sheet with FlowLayout for better button wrapping
- **Larger Spray Charts:** Doubled spray chart size from 200x200 to 400x400 for better readability
- **Text Size Controls:** Added text size picker in Settings > Appearance (System/Small/Medium/Large/Extra Large)
- **Better Layout:** All hit type, pitch type, and pitch location options now visible without scrolling

## Architecture

### Data Models
- **Team:** Opponent team (id, name)
- **Player:** Player on opponent roster (id, teamId, name, number, lineupOrder)
- **Hit:** Individual hit record (id, playerId, teamId, locationX/Y, hitType, pitchType, pitchLocation, timestamp)

### Data Persistence
- **Storage:** NSUbiquitousKeyValueStore (iCloud) + UserDefaults (local fallback)
- **Sync:** Automatic cross-device sync via iCloud
- **Real-time Updates:** App refreshes when data changes from another device

## Build Commands

### Development
```bash
cd /Users/cfore/Desktop/HitTracker
xcodebuild -scheme HitTracker -destination 'platform=iOS Simulator,name=iPhone 17' build
```

### App Store Archive
```bash
cd /Users/cfore/Desktop/HitTracker
xcodebuild archive -scheme HitTracker \
  -archivePath ~/Desktop/HitTracker/build/HitTrackPro.xcarchive \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=Z7AM7M3YT2
```

### Open Archive
```bash
open ~/Desktop/HitTracker/build/HitTrackPro.xcarchive
```

## Increment Build
```bash
./increment-build.sh
```
