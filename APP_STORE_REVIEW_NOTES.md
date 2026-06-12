# App Store Review Notes - Copy into App Review Information

Reviewer Instructions for Murade Zema:

1. Guideline 3.1.1 Compliance:
   We have removed all third-party payment gateways for iOS users.
   All digital content (books, audio, video) is sold exclusively through
   Apple In-App Purchases (Non-Consumables). We use StoreKit 2 for local,
   on-device validation.

2. Guideline 5.1.1 Compliance:
   Users can browse the entire catalog as a Guest without logging in.
   Account creation is only required when attempting to make a purchase
   or access personalized features.

3. Restore Purchases:
   A "Restore Purchases" button is available in the Profile menu
   (gear icon → Edit Profile → Restore Purchases icon).
   This recovers all previously purchased content if the user reinstalls.

4. Test Account Credentials:
   Username: [PROVIDE A TEST ACCOUNT]
   Password: [PROVIDE THE PASSWORD]
   Note: This is a fresh account to test the IAP purchase flow.

5. In-App Purchase Products:
   All IAP products are Non-Consumable type.
   Product IDs follow format: com.app.muradezema.[type].[id]
   Example: com.app.muradezema.audio.123

6. Privacy:
   NSMicrophoneUsageDescription is included for audio recording features.
   No user tracking. No data collection beyond account creation.
   ITSAppUsesNonExemptEncryption is set to false.

7. App Icon:
   All app icons are properly formatted without alpha channels.

8. Platform Support:
   iOS only submission. Android and Web versions use alternative
   payment methods per platform guidelines.
