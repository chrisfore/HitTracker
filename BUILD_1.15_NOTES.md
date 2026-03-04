# Version 1.15 Build 1 - Development Notes

**Date:** March 4, 2026
**Version:** 1.15 (Build 1)
**Status:** Ready for archive and App Store submission

## Changes Made

### 1. In-App Purchase - Pro Data Export ($2.99)
**Feature:** Non-consumable StoreKit 2 in-app purchase gates all export and data sharing features.

**Gated Features:**
- PDF Report Export (Results tab)
- Share Player Data (Settings > Data Management)
- Share Team Data (Settings > Data Management)
- Share All Data (Settings > Data Management)
- Import Shared Data (Settings > Data Management)

**Free Features (unchanged):**
- All hit tracking and recording
- Spray charts and analytics
- Team/player management
- Clear Player Hits / Clear All Hit Data
- iCloud sync
- Dark mode, text size controls

**New File:**
- `HitTracker/StoreKitManager.swift` — StoreKit 2 manager (singleton, @MainActor)
  - Product loading, purchase flow, restore purchases
  - Transaction listener for background updates
  - UserDefaults caching for offline access
  - Entitlement verification on launch

**Product Details:**
- Product ID: `com.cfore.hittracker.dataexport`
- Type: Non-consumable
- Price: $2.99
- Display Name: "Pro Data Export"

### 2. Purchase UI Integration

**Results Tab (ResultsView.swift):**
- Export to PDF button shows lock icon when not purchased
- Tapping shows alert with 3 options:
  - "Unlock Data Export and Management ($2.99)" — initiates purchase
  - "See a Sample Report" — generates sample PDF with placeholder data
  - "Cancel"
- Purchase error alert if purchase fails

**Settings Tab (SettingsView.swift):**
- Share Player/Team/All Data and Import show lock icons when not purchased
- Tapping gated features shows purchase prompt alert
- New "Purchases" section with:
  - "Unlock Data Export and Management" button (or "Unlocked" status)
  - "Restore Purchases" button (Apple-compliant)
- Purchase error alert if purchase fails

### 3. Sample Report
- Generates PDF with 2 placeholder hits (no real player data)
- Orange "SAMPLE" banner at top of PDF
- Title: "HitTracker Sample Report"
- Watermark at bottom: "SAMPLE — Purchase Pro Export to include all Hit Information"

### 4. StoreKit Configuration File
- `HitTracker/Configuration.storekit` for local/simulator testing
- Must be linked in scheme (Run > Options > StoreKit Configuration) for simulator testing

### 5. Help Documentation Updated
- New "Pro Data Export" section in HelpView.swift
- Explains $2.99 one-time purchase and what it unlocks
- Mentions sample report preview and restore purchases

### 6. Version Updated
- Version: 1.0 → 1.15
- Build: 4 → 1

## Files Created
```
HitTracker/StoreKitManager.swift       - StoreKit 2 IAP manager
HitTracker/Configuration.storekit      - StoreKit testing config
```

## Files Modified
```
HitTracker/AppVersion.swift            - Version 1.15, Build 1
HitTracker/HitTrackerApp.swift         - StoreKitManager injection, product loading
HitTracker/ResultsView.swift           - PDF export gating, sample report, purchase alerts
HitTracker/SettingsView.swift          - Data management gating, Purchases section, restore
HitTracker/HelpView.swift              - Pro Data Export help section
HitTracker.xcodeproj/project.pbxproj   - Version/build, new file references
```

## App Store Connect Setup Required
1. Create in-app purchase in App Store Connect:
   - Product ID: `com.cfore.hittracker.dataexport`
   - Type: Non-Consumable
   - Price: $2.99
   - Display Name: "Pro Data Export"
   - Description: "Unlock full PDF report exports and data sharing features."
2. Submit IAP for review alongside the app binary

## Testing
- Clean build successful on iPhone 17 simulator
- Clean build successful on iPad Air 11-inch simulator
- No compiler warnings
- For IAP testing: link Configuration.storekit in scheme, or use TestFlight

---
**Developer:** CROSSFIRE-FORE INC.
**Assisted by:** Claude Opus 4.6
