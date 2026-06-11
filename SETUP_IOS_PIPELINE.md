# iOS CI/CD Pipeline - Complete Setup Guide
# Copy everything below and follow step by step.

================================================================================
STEP 1: CREATE MATCH CERT REPO
================================================================================
Create a private GitHub repo for certificates (e.g., your-org/ios-certs).
Generate a Personal Access Token with 'repo' scope.

================================================================================
STEP 2: ADD GITHUB SECRETS (Settings > Secrets > Actions)
================================================================================
APPSTORE_KEY_ID        = your-appstore-key-id
APPSTORE_ISSUER_ID     = your-issuer-id  
APPSTORE_P8_BASE64     = base64-output-of-your-p8-file
APPLE_TEAM_ID          = your-team-id
APPLE_BUNDLE_ID        = com.your.bundleid
MATCH_GIT_URL           = https://YOUR_PAT@github.com/your-org/ios-certs.git
MATCH_PASSWORD          = your-encryption-password
MATCH_GIT_BASIC_AUTHORIZATION = base64-of-username:PAT

================================================================================
STEP 3: CREATE FILES (copy each file to the exact path shown)
================================================================================

--- .github/workflows/main.yml ---
name: iOS Build & Upload
on:
  workflow_dispatch:
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Select Newest Xcode
        run: |
          NEWEST=$(ls -d /Applications/Xcode*.app 2>/dev/null | sort -V | tail -1)
          sudo xcode-select -s "$NEWEST/Contents/Developer"
          xcodebuild -version
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          flutter-version: '3.41.9'
      - run: flutter pub get
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
          working-directory: ios
      - run: gem install cocoapods
      - run: pod install --repo-update
        working-directory: ios
      - name: Fastlane
        env:
          APPSTORE_KEY_ID: ${{ secrets.APPSTORE_KEY_ID }}
          APPSTORE_ISSUER_ID: ${{ secrets.APPSTORE_ISSUER_ID }}
          APPSTORE_P8_BASE64: ${{ secrets.APPSTORE_P8_BASE64 }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
          APPLE_BUNDLE_ID: ${{ secrets.APPLE_BUNDLE_ID }}
          MATCH_GIT_URL: ${{ secrets.MATCH_GIT_URL }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          MATCH_GIT_BASIC_AUTHORIZATION: ${{ secrets.MATCH_GIT_BASIC_AUTHORIZATION }}
          GITHUB_RUN_NUMBER: ${{ github.run_number }}
        run: bundle exec fastlane ios beta
        working-directory: ios
      - name: Upload Xcode Logs
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: xcodebuild-logs
          path: build/ios/logs/

--- ios/fastlane/Fastfile ---
default_platform(:ios)
platform :ios do
  lane :beta do
    setup_ci
    api_key = app_store_connect_api_key(
      key_id: ENV["APPSTORE_KEY_ID"],
      issuer_id: ENV["APPSTORE_ISSUER_ID"],
      key_content: ENV["APPSTORE_P8_BASE64"],
      is_key_content_base64: true,
      in_house: false
    )
    match(
      type: "appstore",
      app_identifier: ENV["APPLE_BUNDLE_ID"],
      git_url: ENV["MATCH_GIT_URL"],
      api_key: api_key,
      readonly: true,
      keychain_name: ENV["MATCH_KEYCHAIN_NAME"] || "fastlane_tmp_keychain",
      keychain_password: ENV["MATCH_KEYCHAIN_PASSWORD"] || ""
    )
    update_code_signing_settings(
      use_automatic_signing: false,
      path: "Runner.xcodeproj",
      team_id: ENV["APPLE_TEAM_ID"],
      code_sign_identity: "Apple Distribution",
      profile_name: ENV["sigh_#{ENV['APPLE_BUNDLE_ID']}_appstore"],
      targets: ["Runner"],
      build_configurations: ["Release"]
    )
    sh("cd .. && flutter build ios --release --no-codesign --build-number=#{ENV['GITHUB_RUN_NUMBER']}")
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "Runner",
      clean: false,
      output_directory: "../build/ios/ipa",
      buildlog_path: "../build/ios/logs",
      export_method: "app-store",
      export_options: {
        signingStyle: "manual",
        provisioningProfiles: {
          ENV["APPLE_BUNDLE_ID"] => ENV["sigh_#{ENV['APPLE_BUNDLE_ID']}_appstore"]
        }
      }
    )
    upload_to_testflight(
      ipa: Dir["../build/ios/ipa/*.ipa"].first,
      api_key: api_key,
      skip_waiting_for_build_processing: true
    )
  end
end

--- ios/fastlane/Matchfile ---
git_url "https://github.com/YOUR_ORG/ios-certs.git"
git_branch "master"
type "appstore"
app_identifier "com.your.bundleid"
username "your@email.com"
team_id "YOUR_TEAM_ID"
storage_mode "git"

--- ios/fastlane/Gemfile ---
source "https://rubygems.org"
gem "fastlane"
gem "cocoapods"

--- ios/ExportOptions.plist ---
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>export</string>
    <key>method</key>
    <string>app-store</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.your.bundleid</key>
        <string>match AppStore com.your.bundleid</string>
    </dict>
</dict>
</plist>

--- ios/Flutter/build.xcconfig ---
DEVELOPMENT_TEAM = YOUR_TEAM_ID
IPHONEOS_DEPLOYMENT_TARGET = 15.0

================================================================================
STEP 4: MODIFY EXISTING PROJECT FILES
================================================================================

1. ios/Runner.xcodeproj/project.pbxproj:
   Change ALL "CODE_SIGN_STYLE = Automatic" to "CODE_SIGN_STYLE = Manual"
   
   Run this command from project root:
   sed -i 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' ios/Runner.xcodeproj/project.pbxproj

2. ios/Podfile - Replace post_install block with:
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       flutter_additional_ios_build_settings(target)
       target.build_configurations.each do |config|
         config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
         config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
         config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = '""'
       end
     end
   end

3. ios/Runner/Info.plist - Add before </dict>:
   <key>ITSAppUsesNonExemptEncryption</key>
   <false/>

4. Remove alpha channel from all app icons:
   pip3 install Pillow
   python3 -c "
   from PIL import Image
   import os
   d='ios/Runner/Assets.xcassets/AppIcon.appiconset'
   for f in os.listdir(d):
       if f.endswith('.png'):
           p=os.path.join(d,f)
           img=Image.open(p)
           if img.mode in ('RGBA','LA'):
               bg=Image.new('RGB',img.size,(255,255,255))
               bg.paste(img,mask=img.split()[3])
               bg.save(p)
               print(f'Fixed: {f}')
   "
   Also fix the main logo:
   python3 -c "
   from PIL import Image
   img=Image.open('assets/images/logocolored.png')
   if img.mode in ('RGBA','LA'):
       bg=Image.new('RGB',img.size,(255,255,255))
       bg.paste(img,mask=img.split()[3])
       bg.save('assets/images/logocolored.png')
   "

================================================================================
STEP 5: FIRST RUN (CREATE CERTIFICATES)
================================================================================

In ios/fastlane/Fastfile, TEMPORARILY change the match block to:
    match(
      type: "appstore",
      app_identifier: ENV["APPLE_BUNDLE_ID"],
      git_url: ENV["MATCH_GIT_URL"],
      api_key: api_key,
      readonly: false,
      force: true,
      force_for_new_certificates: true,
      keychain_name: ENV["MATCH_KEYCHAIN_NAME"] || "fastlane_tmp_keychain",
      keychain_password: ENV["MATCH_KEYCHAIN_PASSWORD"] || ""
    )

Trigger workflow. After it succeeds, REVERT to readonly: true and remove force flags.

================================================================================
DART CODE FIXES (for this specific project)
================================================================================

lib/screens/splash_screen.dart:
  - Import 'audio_home.dart' NOT 'books_home.dart'
  - Import '../commons/custom_text.dart'
  - Remove forced login check (always navigate to BookHomeScreen)

lib/utils/dio_client.dart (NEW FILE):
  - Creates Dio instance with interceptor that auto-attaches Bearer token
  - Strips null tokens for guest users
  - Import this in all files that create Dio instances

lib/screens/notification_screen.dart:
  - Remove lucide_icons dependency
  - Replace LucideIcons with Material Icons

pubspec.yaml:
  - Remove lucide_icons dependency
  - Run: rm pubspec.lock && flutter pub get

================================================================================
KNOWN ISSUES & QUICK FIXES
================================================================================

"No profiles found" 
  → Ensure update_code_signing_settings is before build_app

"Pod targets don't support provisioning profiles"
  → CODE_SIGNING_REQUIRED=NO in Podfile post_install

"Certificate not available on Developer Portal"
  → Delete stale certs from Match repo (use GitHub API or web UI)

"Invalid large app icon - alpha channel"
  → Run the Pillow script above to strip alpha from all PNG icons

"SDK version too old"
  → The 'Select Newest Xcode' step in workflow handles this

"flutter build ipa crashes instantly (0 seconds)"
  → NEVER use pipe (| tee) in Fastlane sh() commands
  → Use Ruby interpolation #{ENV['VAR']} instead of $VAR

"New GitHub account Actions not working"
  → Make repo temporarily public, or add payment method

"match_nuke needs interactive confirmation on CI"
  → Don't use match_nuke. Use force: true + force_for_new_certificates: true

"Redundant Binary Upload error"
  → Build number is auto-incremented via GITHUB_RUN_NUMBER

"Ruby syntax error in Fastfile"
  → Check for missing commas at end of parameter lines

================================================================================
PIPELINE FLOW (What happens when you trigger)
================================================================================

1. setup_ci → Creates temp keychain, sets partition list (prevents GUI hang)
2. match → Pulls encrypted certs from git repo → installs to temp keychain
3. update_code_signing_settings → Sets Runner target to Manual/Distribution
4. flutter build ios --no-codesign → Compiles Dart to .app
5. build_app (gym) → Archives .xcarchive, signs with match certs, exports .ipa
6. upload_to_testflight → Uploads to App Store Connect
