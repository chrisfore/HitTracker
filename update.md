# Hit Track Pro - Claude Context Document

## Overview
Hit Track Pro is a universal SwiftUI iOS app for tracking softball/baseball hits against opponent teams. Coaches scout multiple opponents, each with their own player roster. Runs natively on iPhone and iPad with full feature parity and cross-device data sync.

## App Details
- **App Name:** Hit Track Pro (App Store display name)
- **Bundle ID:** `com.cfore.hittracker`
- **Current Version:** 1.15 - Build 1
- **Deployment Target:** iOS 17.0
- **Supported Devices:** iPhone and iPad (Universal App)
- **Swift Version:** 5.0
- **Development Team:** Z7AM7M3YT2 (CROSSFIRE-FORE INC.)
- **Repository:** https://github.com/chrisfore/HitTracker.git (public - docs only)
- **App Store Status:** Version 1.15 - In-app purchase for data export

### Versioning Strategy
- **Marketing Version:** 1.15
- **Build Number:** 1
- To increment build: `./increment-build.sh` (updates both AppVersion.swift and project.pbxproj)

### Privacy & Legal
- **Privacy Policy:** https://chrisfore.github.io/HitTracker/privacy-policy.html
- **Support URL:** https://chrisfore.github.io/HitTracker/
- **Copyright:** 2026 CROSSFIRE-FORE INC.

## Key Features
1. **Hit Tracking** - Tap softball field to record hit location, type, and pitch details
2. **Multiple Teams** - Track multiple opponent teams, each with their own roster
3. **Live Stats** - Spray charts, hit type breakdown, pitch location analysis
4. **PDF Export** - Professional reports with team logo and date filtering (Pro Data Export)
5. **Data Sharing** - Share player/team/all data as .hitdata files with other coaches (Pro Data Export)
6. **Data Import** - Import shared .hitdata files via document picker or tap-to-open (Pro Data Export)
7. **In-App Purchase** - One-time $2.99 non-consumable purchase unlocks all export/sharing features
8. **iCloud Sync** - Automatic sync across all Apple devices
9. **Dark Mode** - Support for light and dark themes
10. **Adjustable Text Size** - Control text size app-wide from Settings

## Recent Changes (Version 1.15 Build 1)
- **In-App Purchase:** Added StoreKit 2 non-consumable IAP to gate export/sharing features
- **Product ID:** `com.cfore.hittracker.dataexport` ($2.99 one-time purchase)
- **Gated Features:** PDF export, Share Player/Team/All Data, Import Shared Data
- **Free Features:** All hit tracking, analytics, spray charts, team/player management
- **Sample Report:** Non-purchasers can preview a sample PDF with placeholder data and watermark
- **Restore Purchases:** Apple-compliant restore button in Settings > Purchases
- **Purchase Error Handling:** Alerts shown on purchase failure
- **StoreKit Config:** Configuration.storekit file for local/simulator testing
- **Help Updated:** New "Pro Data Export" section explaining the purchase

## Previous Changes (Build 4)
- **Data Sharing:** Share player, team, or all data as .hitdata files via share sheet
- **Data Import:** Import shared data via document picker or by tapping a .hitdata file
- **Custom File Type:** Registered .hitdata UTType so iOS opens files directly in Hit Track Pro
- **Help Updated:** Added sharing & importing documentation to in-app help

## Previous Changes (Build 3)
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

### In-App Purchase (StoreKit 2)
- **Manager:** StoreKitManager singleton (@MainActor, ObservableObject)
- **Product:** Non-consumable, ID `com.cfore.hittracker.dataexport`
- **Persistence:** UserDefaults cache for offline access, verified with StoreKit on launch
- **Transaction Listener:** Background task for transaction updates
- **Injected as:** @EnvironmentObject from HitTrackerApp

## Build Commands

### Development
```bash
cd "/Volumes/data/Apple Apps/HitTracker"
xcodebuild -scheme HitTracker -destination 'platform=iOS Simulator,name=iPhone 17' build
```

### App Store Archive
```bash
cd "/Volumes/data/Apple Apps/HitTracker"
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
