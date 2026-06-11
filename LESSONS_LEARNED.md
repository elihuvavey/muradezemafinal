# iOS CI/CD on GitHub Actions - Lessons Learned
# 3 Days, 100+ Tests, 4 GitHub Accounts
# For the next developer (human or AI)

================================================================================
THE GOLDEN RULE
================================================================================

You CAN build and sign Flutter iOS apps on GitHub Actions without a Mac.
But you must use THIS EXACT architecture. Any deviation will fail.

================================================================================
WHAT WORKS (Proven 100+ times)
================================================================================

1. Fastlane Match with private git repo for certificates
   - Stores certs encrypted, no Apple limits, works across CI runs
   - MUST use setup_ci + temp keychain to prevent codesign GUI hang

2. Flutter build ios --no-codesign (NOT flutter build ipa)
   - flutter build ipa crashes in Fastlane sh() due to PTY issues
   - flutter build ipa has pipe problems, silent failures, SDK issues
   - flutter build ios --no-codesign is stable and predictable

3. Fastlane gym (build_app) for archive + signing
   - Gym natively understands Match profiles
   - Separates compile from sign - each step debuggable independently
   - Use clean: false (flutter already compiled)

4. Manual code signing (NOT Automatic)
   - Automatic signing requires Apple ID login on CI (impossible)
   - update_code_signing_settings sets Release config to Manual/Distribution
   - Pod targets must have CODE_SIGNING_REQUIRED=NO

5. setup_ci with temp keychain
   - Creates keychain, sets partition list
   - Prevents macOS codesign permission dialog (would hang CI forever)
   - Match must use same keychain via keychain_name parameter

================================================================================
WHAT DOESN'T WORK (We tried everything)
================================================================================

1. flutter build ipa in Fastlane sh()
   - Crashes at 0 seconds if piped with | tee
   - Silent failures with no error output
   - Environment variables don't pass correctly
   - PTY (pseudo-terminal) issues in Fastlane

2. Automatic code signing (CODE_SIGN_STYLE=Automatic)
   - Requires Apple ID logged into Xcode GUI
   - CI runners have no GUI, no Apple ID session
   - Error: "No Accounts: Add a new account in Accounts settings"

3. xcodebuild with PROVISIONING_PROFILE_SPECIFIER on command line
   - Applies specifier to ALL targets including Pods
   - Pods don't support provisioning profiles
   - Error: "X does not support provisioning profiles"

4. increment_build_number (agvtool)
   - Requires Apple Generic versioning system enabled
   - Flutter ignores Xcode build numbers anyway
   - Use --build-number flag on flutter build instead

5. match_nuke on CI
   - Requires interactive terminal confirmation
   - Use force: true + force_for_new_certificates instead

6. New GitHub accounts
   - Actions silently blocked for hours/days
   - Must make repo public temporarily or add payment method
   - No bypass, no API call, no workaround

7. Codemagic free tier
   - Personal accounts can't use automatic code signing
   - Only works on paid Team plans

================================================================================
CRITICAL DETAILS THAT BREAK EVERYTHING
================================================================================

1. Commas in Ruby Fastfile
   - Missing comma after xcargs: line = syntax error
   - Missing comma after any parameter = crash

2. Signing identity name
   - Must be EXACT: "Apple Distribution" (not "Apple Distribution: Name")
   - update_code_signing_settings handles the full name lookup

3. Sigh environment variable
   - Match exports: sigh_com.your.app_appstore (NOT ..._profile-name)
   - Getting this wrong = nil profile = signing failure

4. Xcode project settings
   - Must change project.pbxproj to CODE_SIGN_STYLE = Manual
   - Flutter build ios migration resets this sometimes

5. App icons
   - ALL must be RGB (no alpha channel)
   - RGBA icons = App Store validation failure
   - 1024x1024 icon especially important

6. ITSAppUsesNonExemptEncryption
   - Missing = App Store rejection
   - Must be in Info.plist

7. Disk space
   - Flutter build needs ~5GB
   - CI runner has limited space
   - build/ folder must be in .gitignore

8. Match git repo
   - Stale/revoked certs in repo = "Certificate not available on Developer Portal"
   - Must manually delete via API if certs revoked from Apple portal

9. GitHub Actions macOS runner
   - macos-latest may have old Xcode
   - Must add step to select newest Xcode for App Store SDK requirements

10. Match keychain_name
    - setup_ci creates "fastlane_tmp_keychain"
    - Match must use same name via ENV["MATCH_KEYCHAIN_NAME"]
    - Otherwise certs go to login keychain (locked, causes hang)

================================================================================
ERROR → CAUSE → FIX (Quick Reference)
================================================================================

"No profiles for 'com.app'" → Automatic signing on CI → Use Manual signing

"reached maximum certificates" → Each run creates new cert → Use Match

"Certificate not available on Portal" → Stale cert in Match repo → Delete via API

"Pod targets don't support provisioning profiles" → Specifier applied globally → CODE_SIGNING_REQUIRED=NO

"Keychain password not specified" → login.keychain is locked → Use setup_ci temp keychain

"flutter build ipa 0 seconds" → Pipe | tee breaks PTY → Don't pipe in sh()

"Ruby syntax error" → Missing comma → Check every line ending

"ARCHIVE FAILED" (no details) → Gym needs manual signing → update_code_signing_settings

"No ipa or pkg file given" → upload_to_testflight can't find IPA → Explicit ipa: path

"Invalid large app icon" → Alpha channel in PNG → Strip to RGB with Pillow

"SDK version issue" → Old Xcode on runner → Select newest Xcode in workflow

"New account Actions blocked" → Anti-spam → Make repo public or add payment

"match_nuke confirmation" → Interactive only → Use force: true instead

"Redundant Binary Upload" → Same build number → Use GITHUB_RUN_NUMBER

"EXPORT FAILED" → Archive path wrong → Check archivePath in xcodebuild

"increment_build_number crash" → agvtool not configured → Use flutter --build-number

"BookHomeScreen not defined" → Wrong import → Import from audio_home.dart

"CustomText not defined" → Missing import → Import ../commons/custom_text.dart

"createDio not defined" → Missing import → Import dio_client.dart

"lucide_icons/IconData final class" → Incompatible version → Remove lucide_icons

================================================================================
THE PIPELINE PATTERN (Memorize This)
================================================================================

setup_ci
  → match(keychain_name: temp, readonly: true)
  → update_code_signing_settings(Manual, Apple Distribution, Release)
  → flutter build ios --release --no-codesign --build-number=N
  → build_app(clean: false, manual signing, match profiles)
  → upload_to_testflight(ipa: explicit path)

DO NOT:
  - Use flutter build ipa
  - Use Automatic signing
  - Use pipes (| tee) in sh()
  - Use increment_build_number
  - Use match_nuke on CI
  - Forget setup_ci
  - Forget keychain_name in match()

================================================================================
ACCOUNT MANAGEMENT
================================================================================

- GitHub Free: 2000 minutes/month for private repos
- Public repos: unlimited free minutes
- New accounts: wait hours or make repo public
- Apple Developer: $99/year, required
- App Store Connect API key: Admin access needed

================================================================================
TIME INVESTMENT
================================================================================

- First successful pipeline: 3 days, 100+ attempts
- With this guide: 30 minutes to set up a new app
- CI build time: 10-15 minutes per run
