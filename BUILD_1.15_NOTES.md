# Version 1.15 Build 1 - Development Notes

**Date:** March 4, 2026
**Version:** 1.15 (Build 1)
**Status:** Ready for archive and App Store submission

## Changes Made

### 1. IAP Removed — Non-Profit App
CROSSFIRE-FORE INC. is a non-profit organization. Apple does not allow in-app purchases for non-profit apps. All previously planned IAP code (StoreKit 2 manager, purchase gating, sample reports) was removed before submission. The app is completely free with all features accessible.

### 2. Version Updated
- Version: 1.0 → 1.15
- Build: 4 → 1

### 3. All Features Free
- PDF Report Export (Results tab) — fully accessible
- Share Player/Team/All Data (Settings > Data Management) — fully accessible
- Import Shared Data (Settings > Data Management) — fully accessible
- Hit tracking, spray charts, analytics — fully accessible
- iCloud sync, dark mode, text size controls — fully accessible

## Files Modified
```
HitTracker/AppVersion.swift            - Version 1.15, Build 1
HitTracker.xcodeproj/project.pbxproj   - Version/build numbers
```

## Testing
- Clean build successful on iPhone 17 simulator
- Clean build successful on iPad Air 11-inch simulator
- No compiler warnings

---
**Developer:** CROSSFIRE-FORE INC.
**Assisted by:** Claude Opus 4.6
