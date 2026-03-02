#!/bin/bash

# Hit Track Pro - Increment Build Number Script
# This script increments only the build number, keeping version at 1.0

set -e

cd "$(dirname "$0")"

# Get current build number
CURRENT_BUILD=$(grep 'static let build = ' HitTracker/AppVersion.swift | sed 's/.*"\(.*\)".*/\1/')
NEW_BUILD=$((CURRENT_BUILD + 1))

echo "📦 Incrementing build number..."
echo "   Current: $CURRENT_BUILD"
echo "   New:     $NEW_BUILD"

# Update AppVersion.swift
sed -i '' "s/build = \"$CURRENT_BUILD\"/build = \"$NEW_BUILD\"/" HitTracker/AppVersion.swift

# Update project.pbxproj (both Debug and Release configurations)
sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT_BUILD;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" HitTracker.xcodeproj/project.pbxproj

echo ""
echo "✅ Build number updated to $NEW_BUILD"
echo ""
echo "📋 Current app version:"
echo "   Version: 1.0 (stays fixed)"
echo "   Build:   $NEW_BUILD"
echo ""
echo "Next steps:"
echo "  1. Clean build: xcodebuild clean -scheme HitTracker"
echo "  2. Archive: See build commands in update.md"
echo "  3. Upload to App Store Connect"
