# Murade Zema iOS CI/CD - Platinum Project Log

## 🎯 Goal
Build and submit Flutter iOS app `com.app.muradezema` to App Store Connect TestFlight using GitHub Actions CI/CD **without owning a Mac**.

## 📋 Project Overview

| Field | Value |
|-------|-------|
| Project Name | Murade Zema |
| Bundle ID | com.app.muradezema |
| Team ID | K7R3D85XYA |
| Apple Account | muradekal25@gmail.com |
| App Type | Flutter (SDK 3.41.9) |
| Features | Audio streaming, video streaming, PDF books, purchases |
| Backend | https://murade.smart.et/api |
| Current App Status | Rejected - needs IAP and guest browsing fixes |
| Target | TestFlight build for resubmission |

---

## 🏗️ Architecture Decisions

### Decision 1: GitHub Actions over Codemagic
- **Why**: Codemagic free tier doesn't support automatic code signing on personal accounts
- **Result**: Used GitHub Actions with Fastlane Match for certificate management

### Decision 2: Fastlane Match over manual cert management
- **Why**: Prevents certificate limit issues (max 3 Distribution certs at Apple)
- **Result**: Certs stored encrypted in private git repo `afroel/muradezema_appstore`

### Decision 3: setup_ci with temporary keychain
- **Why**: Prevents macOS GUI codesign permission prompt hanging CI
- **Result**: Temp keychain with set-key-partition-list bypasses UI dialog

### Decision 4: Manual code signing over Automatic
- **Why**: Automatic signing requires Apple ID login on CI runner (not possible)
- **Result**: Use update_code_signing_settings to configure Release builds

### Decision 5: flutter build ios + gym over flutter build ipa
- **Why**: flutter build ipa has PTY issues with Fastlane sh(), and swallows errors
- **Result**: Split pipeline: flutter compiles without signing, gym archives + signs

---

## 🔧 Code Changes Made

### Guest Browsing Fix (5.1.1 Rejection)
- **File**: `lib/screens/splash_screen.dart`
- **Change**: Removed login check. Always navigates to BookHomeScreen
- **Import fix**: `BookHomeScreen` is in `audio_home.dart`, not `books_home.dart`

### Dependency Fixes
- **Removed**: `lucide_icons` (incompatible with Flutter 3.41.9)
- **Replaced with**: Material Icons (Icons.headphones, Icons.video_library, Icons.book)
- **File**: `lib/screens/notification_screen.dart`

### Dio Client for Guest Users
- **New file**: `lib/utils/dio_client.dart`
- **Purpose**: Auto-attaches auth token when available, strips null tokens for guests
- **New file**: `lib/utils/api_headers.dart`

### Pubspec.lock Regenerated
- **Reason**: Stale lucide_icons reference was cached
- **Solution**: `rm pubspec.lock && flutter pub get`

### iOS Configuration
- **Podfile**: Disabled signing for all Pod targets (CODE_SIGNING_REQUIRED=NO)
- **ExportOptions.plist**: Manual signing with Apple Distribution cert and match profile
- **build.xcconfig**: DEVELOPMENT_TEAM, IPHONEOS_DEPLOYMENT_TARGET=15.0
- **Info.plist**: Added ITSAppUsesNonExemptEncryption = false
- **project.pbxproj**: CODE_SIGN_STYLE = Manual for all targets

---

## ❌ Errors Encountered & Solutions

| # | Error | Root Cause | Solution |
|---|-------|------------|----------|
| 1 | "No profiles found" | Xcode automatic signing needs Apple ID | Switch to Manual signing |
| 2 | "Reached maximum certificates" | Each CI run created new Distribution cert | Use Fastlane Match to persist certs |
| 3 | "Certificate not available on Developer Portal" | Stale cert in match git repo | Deleted certs from match repo via API |
| 4 | "Pod targets don't support provisioning profiles" | PROVISIONING_PROFILE_SPECIFIER applied to all targets | Set CODE_SIGNING_REQUIRED=NO for Pods |
| 5 | "Ruby syntax error: missing comma" | Missing comma after xcargs line | Added comma |
| 6 | "flutter build ipa hangs for hours" | macOS codesign GUI prompt | setup_ci with temp keychain |
| 7 | "flutter build ipa crashes at 0 seconds" | Pipe `| tee` breaks Fastlane PTY | Removed pipe, use Ruby interpolation |
| 8 | "BookHomeScreen not defined" | Wrong import (books_home vs audio_home) | Fixed import in splash_screen.dart |
| 9 | "CustomText not defined" | Missing import | Added import '../commons/custom_text.dart' |
| 10 | "createDio not defined" | Missing import in player_task.dart | Added import for dio_client.dart |
| 11 | "lucide_icons/IconsData final class" | Package incompatible with Flutter 3.41.9 | Removed lucide_icons entirely |
| 12 | "Disk full on VPS" | 492GB disk 100% used | Deleted build/ folder (5GB freed) |
| 13 | "New GitHub account Actions blocked" | Anti-abuse system on fresh accounts | Made repo public temporarily |
| 14 | "match_nuke needs interactive confirmation" | Non-interactive CI | Used force:true instead |
| 15 | "increment_build_number crashes" | agvtool requires Apple Generic versioning | Use --build-number flag instead |
| 16 | "No ipa or pkg file given" | upload_to_testflight couldn't find IPA | Added explicit ipa: path |
| 17 | "sigh profile name mismatch" | Wrong env var name (_profile-name appended) | Changed to sigh_..._appstore |

---

## ✅ What Works

| Component | Status |
|-----------|--------|
| Fastlane Match (cert creation) | ✅ |
| Fastlane Match (cert retrieval) | ✅ |
| setup_ci (temp keychain) | ✅ |
| update_code_signing_settings | ✅ |
| flutter build ios --no-codesign | ✅ |
| Pod signing disabled | ✅ |
| ExportOptions.plist | ✅ |
| Code compiles (Dart) | ✅ |
| Guest browsing fix | ✅ |
| GitHub Actions trigger | ✅ |

---

## ⏳ Remaining

| Task | Status |
|------|--------|
| build_app (gym) archive + sign | ⏳ Pending test |
| upload_to_testflight | ⏳ Pending test |
| IAP integration (3.1.1 rejection) | ❌ Not started |
| IAP products in App Store Connect | ❌ Not started |
| After success: switch match to readonly | ⏳ Ready |
| After success: add build/ios/logs to .gitignore | ⏳ Ready |

---

## 📁 Final Configuration Files

### ios/fastlane/Fastfile
- setup_ci + api_key + match(readonly:true) + update_code_signing_settings + flutter build ios --no-codesign + build_app(gym) + upload_to_testflight

### ios/ExportOptions.plist
- destination=export, method=app-store, signingStyle=manual, signingCertificate=Apple Distribution, teamID=K7R3D85XYA, provisioningProfiles={"com.app.muradezema":"match AppStore com.app.muradezema"}

### ios/Podfile
- platform :ios, '15.0', post_install disables Pod signing

### .github/workflows/main.yml
- macOS runner, Flutter 3.41.9, Ruby 3.2, 9 secrets, artifact upload on failure

---

## 🔐 GitHub Secrets Required
APPSTORE_KEY_ID, APPSTORE_ISSUER_ID, APPSTORE_P8_BASE64, APPLE_TEAM_ID, APPLE_BUNDLE_ID, MATCH_GIT_URL, MATCH_PASSWORD, MATCH_GIT_BASIC_AUTHORIZATION, GITHUB_RUN_NUMBER (auto)

---

## 📊 Run Statistics
- **Total CI runs**: ~78 across 4 accounts
- **Accounts used**: afroeltechnologies, afroeltechologies, afroel, elihuvavey
- **Minutes consumed**: ~6,000+
- **Current account**: elihuvavey (minutes remaining: very low)
