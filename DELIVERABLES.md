# Yes Chef — Delivery & Next Steps

## Status — Work completed (Milestone 1)
- Full UI prototype implemented:
  - Splash screen, bottom navigation, 4 main sections (My Recipes, Add Recipe, Calendar, Grocery Lists).
  - Recipe list/detail UI with prominence indexing, tags (Meal/Diet/Supplemental), ratings, cooked status.
  - Advanced search UI (general + prominent/index search).
  - Recipe scaling (0.5 increments) and recipe detail flows.
  - Add Recipe screen (URL, OCR, Manual) as UI — OCR/URL marked "Milestone 2".
  - Grocery list UI with pantry vs to-buy, shopping mode, aisle categorization.
- Mock data and demo recipes included for presentation.
- App runs as a pure UI prototype using core Flutter only (no OCR/web-scraping packages).
- APK prepared for Android testing (attach `yes_chef_milestone1.apk` to deliverables).

## Current milestone
- Milestone 1: COMPLETE — UI prototype ready for client demo and feedback.

## Milestone 2 — Prioritized work (what to do next)
1. Recipe Import (high priority)
   - Integrate URL scraping (http + html): implement parser, mapping to recipe model.
   - Build review & edit screen for scraped results.
2. OCR (high priority)
   - Add image picker / camera and google_ml_kit text recognition.
   - Implement confidence scoring: <60% prompt retry; highlight low-confidence tokens for user verification.
   - Save original photo to Firebase Storage (or local for MVP).
3. Backend & Sync (parallel)
   - Firebase Auth + Firestore + Storage integration for cloud sync and collaboration.
   - Offline cache + sync queue (basic LWW conflict handling).
4. Auto-tagging & Rules
   - Implement rule-based tags (prominence thresholds, meal/diet exclusions).
   - Integrate an AI tag suggestion hook (deferred to server or local ML).
5. Calendar & Grocery enhancements
   - Calendar export, event scaling based on guest count, grocery aggregation across date ranges.
   - Unit conversions, packaging heuristics, excess tracking logic.

## Immediate checklist before Milestone 2 dev
- [ ] Remove any placeholder files importing packages not in pubspec (or add packages to pubspec if proceeding).
- [ ] Add/confirm dependencies in pubspec.yaml:
  - google_ml_kit, image_picker, http, html, firebase_core, cloud_firestore, firebase_storage.
- [ ] Create `features/recipe_import/` skeleton (ocr_service, web_scraper) and unit tests.
- [ ] Run `flutter clean` → `flutter pub get` → `flutter analyze`.
- [ ] Prepare Firebase project credentials and environment variables (staging).

## Estimated Milestone 2 plan (20 working days total project—phase within next sprint)
- Week 1: URL scraper + review screen, basic parser tests.
- Week 2: OCR integration + confidence highlighting + review UI.
- Week 3: Firebase integration, save/load recipe flows, image upload.
- Week 4: Auto-tagging baseline, calendar/grocery aggregation, QA and polishing.

## Deliverables & Handoff
- Android APK: `yes_chef_milestone1.apk` (attached in release assets).
- iOS: IPA/TestFlight build available upon request (need Apple dev credentials or CI).
- Assets: `assets/images/splash.png` and UI screenshots attached.
- Documentation: this `DELIVERABLES.md`, code comments, and PRD mapping included.

## Notes / Next Actions for you
- Confirm priorities for Milestone 2 (OCR vs URL scraping first).
- Provide Firebase project access or indicate whether local-first storage is preferred.
- Share any additional site-specific scraping targets or edge-case sources.

