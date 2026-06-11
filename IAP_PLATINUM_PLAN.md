# IAP Integration - Platinum Standard Plan
# Murade Zema iOS App Store Submission
# Guideline 3.1.1 Compliance

================================================================================
OVERVIEW
================================================================================
Current: Payments via PayPal, SantimPay, Bank Transfer (rejected by Apple)
Target:  Apple In-App Purchase for iOS, keep existing methods for Android/Web
Result:  App Store approved, all platforms functional

================================================================================
ARCHITECTURE
================================================================================

User taps "Buy" on iOS
  → Flutter shows Apple Pay Sheet (StoreKit)
  → User confirms payment with Face ID / Touch ID
  → Apple processes payment
  → Flutter receives receipt (base64 string)
  → Flutter sends receipt to murade.smart.et/api/verify-iap
  → Backend validates receipt with Apple's servers
  → Backend unlocks content in database
  → Backend returns 200 OK to Flutter
  → Flutter completes transaction with Apple
  → User accesses purchased content

Android/Web: Keep PayPal, SantimPay, Bank Transfer (unchanged)

================================================================================
PHASE 1: APP STORE CONNECT SETUP
================================================================================

1. Sign Paid Applications Agreement
   - Go to App Store Connect → Agreements, Tax, and Banking
   - Sign the Paid Applications agreement
   - Provide banking/tax information
   - IAP WILL NOT WORK without this

2. Create IAP Products
   - Go to App Store Connect → Murade Zema → Features → In-App Purchases
   - Create products based on content types:
   
   For individual audio/albums (Non-Consumable):
     com.app.muradezema.audio.[id]
     Example: com.app.muradezema.audio.123
   
   For individual books/PDFs (Non-Consumable):
     com.app.muradezema.book.[id]
     Example: com.app.muradezema.book.456
   
   For seasons (Non-Consumable):
     com.app.muradezema.season.[id]
     Example: com.app.muradezema.season.789
   
   For podcasts (Non-Consumable):
     com.app.muradezema.podcast.[id]
     Example: com.app.muradezema.podcast.101

3. Product Configuration (for each):
   - Type: Non-Consumable
   - Reference Name: Human-readable (e.g., "Audio - Song Title")
   - Product ID: As above
   - Price: Set in USD (with tiers)
   - Display Name: Shown in purchase sheet
   - Description: Brief description
   - Review Screenshot: Screenshot of the digital content
   - Review Notes: Explain what the user gets

================================================================================
PHASE 2: FLUTTER CODE CHANGES
================================================================================

FILE 1: lib/services/iap_service.dart (NEW)
-------------------------------------------
Purpose: Centralized IAP management
- Initialize InAppPurchase on app startup
- Listen to purchase stream (handles pending, completed, errors)
- Query products from App Store
- Initiate purchases
- Restore purchases
- Verify receipts via backend API
- Complete transactions

Methods:
  init()                    - Initialize, listen to purchase stream
  dispose()                 - Cancel subscriptions
  fetchProducts(ids)        - Get product details from Apple
  purchase(product)         - Trigger Apple Pay sheet
  restorePurchases()        - Restore button handler
  _verifyReceipt(details)   - Send to backend
  _completePurchase(details) - Mark complete in Apple's queue

FILE 2: lib/provider/purchase_provider.dart (MODIFY)
-----------------------------------------------------
- Add IAP product fetching
- Add purchase state management (loading, error, success)
- Keep existing backend purchase tracking
- Add method: isAudioPurchasedViaIAP(audioId)
- Add method: isBookPurchasedViaIAP(bookId)
- Sync IAP purchases with existing HivePrefs storage

FILE 3: lib/screens/payment_screen.dart (MODIFY)
--------------------------------------------------
- WRAP in Platform check:
  if (Platform.isIOS) {
    // Show only Apple IAP buttons
    // Fetch IAP products
    // Display prices from App Store
    // Handle Apple Pay flow
  } else {
    // Existing PayPal/SantimPay/Bank flow (unchanged)
  }

- Add IAP UI elements:
  - Product list with App Store prices
  - "Buy with Apple Pay" button
  - Loading spinner during purchase
  - Error/retry dialog
  - Restore purchases link

FILE 4: lib/screens/profile_screen.dart (MODIFY)
--------------------------------------------------
- Add "Restore Purchases" button (iOS only)
- Required by Guideline 3.1.2
- Calls iapService.restorePurchases()

FILE 5: lib/utils/dio_client.dart (EXISTING - NO CHANGE)
---------------------------------------------------------
- Already handles auth tokens for API calls

FILE 6: lib/main.dart (MODIFY)
-------------------------------
- Initialize IAP service in main()
- Register purchase stream listener

================================================================================
PHASE 3: BACKEND CHANGES (murade.smart.et)
================================================================================

NEW ENDPOINT: POST /api/verify-iap
-----------------------------------
Request:
{
  "receipt_data": "base64_apple_receipt_string",
  "user_id": 123,
  "product_id": "com.app.muradezema.audio.456"
}

Backend Logic:
1. POST receipt to https://buy.itunes.apple.com/verifyReceipt
   (Use https://sandbox.itunes.apple.com/verifyReceipt for testing)
2. If status == 0 (valid):
   - Parse receipt for product_id
   - Unlock content in database for user_id
   - Return { "success": true, "message": "Purchase verified" }
3. If status != 0:
   - Return { "success": false, "message": "Invalid receipt" }

MODIFY EXISTING: GET /api/my-purchases?type=audio
--------------------------------------------------
- Include IAP purchases in response
- Track purchase source (iap vs paypal vs bank)

================================================================================
PHASE 4: TESTING
================================================================================

1. Sandbox Testing
   - Create Sandbox tester in App Store Connect
   - Sign in on test device with Sandbox account
   - Test purchase flow end-to-end
   - Test restore purchases
   - Test error cases (cancel payment, network failure)

2. Receipt Validation Testing
   - Verify backend receives and validates receipts
   - Verify content unlocks correctly
   - Verify duplicate receipts handled

3. Edge Cases
   - Purchase interrupted (app closed mid-payment)
   - Network failure during verification
   - User changes Apple ID
   - Restore on new device
   - Existing purchases from old system migration

================================================================================
PHASE 5: SUBMISSION
================================================================================

Pre-submission Checklist:
[ ] Paid Applications Agreement signed
[ ] All IAP products created and approved
[ ] IAP code tested in Sandbox
[ ] Restore Purchases button present
[ ] No external payment methods visible on iOS
[ ] No mention of PayPal/TeleBirr in iOS UI
[ ] Privacy strings added (microphone, etc.)
[ ] App icon has no alpha channel
[ ] Build 47 or later uploaded to TestFlight

Submit for Review:
- In App Store Connect → App Review → Submit
- Provide review notes:
  - Sandbox tester credentials
  - How to access purchasable content
  - List of IAP product IDs

================================================================================
MIGRATION STRATEGY
================================================================================

Problem: Existing users purchased content via PayPal/Bank Transfer.
         They will lose access if we only check IAP purchases.

Solution: Check BOTH sources:
  bool hasAccess = isPurchasedViaIAP(contentId) || isPurchasedViaLegacy(contentId);

Legacy purchases from backend (HivePrefs 'purchased_audio_ids') still work.
New iOS purchases go through IAP.
Android/Web purchases continue through existing payment gateways.

================================================================================
TIMELINE
================================================================================

Phase 1 (App Store Connect): 1-2 hours (depends on agreement approval)
Phase 2 (Flutter Code): 4-6 hours
Phase 3 (Backend): 2-3 hours
Phase 4 (Testing): 2-3 hours
Phase 5 (Submission): 30 minutes

Total estimated: 10-15 hours
