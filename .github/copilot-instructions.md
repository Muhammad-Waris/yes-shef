# Yes Chef - Recipe & Meal Planning App

## Project Overview

"Yes Chef" is a comprehensive Flutter mobile application for iOS and Android that helps users manage personal recipes, plan meals, and generate smart grocery lists. The app aims to be a polished, full-featured solution with advanced capabilities like URL scraping, OCR, and intelligent meal planning.

**Client**: Bailey Bennett (bbennett106)  
**Timeline**: 20-25 days development + testing + deployment  
**Figma Prototype**: https://photo-spent-33241045.figma.site/

## Core Features & Requirements

### 1. Recipe Import & Management System
**URL Scraping**:
- Scrape title, ingredients (with amounts/units), instructions, original yield, and recipe photo
- Final review screen for user verification and editing before save
- Save user's final edited version as canonical recipe

**OCR & Image Processing**:
- Two input options: "Upload from file/photo" or "Take photo in moment" 
- OCR confidence validation: <60% confidence = retry prompt
- Low confidence highlighting (yellow) for fractions/numbers requiring user verification
- Original photo saved as attachment to recipe record
- Final confirmation screen displaying complete recipe before save

**Technical Requirements**:
- Use `google_ml_kit` for OCR processing
- `http` + `html` packages for web scraping
- Image storage with Firebase Storage
- OCR metadata suggestion for cookbook title/author from scanned images

### 2. Advanced Tagging & Search System
**Automatic Tag Proposal**:
- AI-powered tag suggestions before save (Meal Type, Diet Type, Supplemental)
- Rule-based tagging with exclusion constraints (meat ↔ vegetarian)
- Bulk application of new tags to entire recipe library

**Tag Taxonomy**:
- **Meal Type**: breakfast, dinner, snacks & apps, dessert, drinks
- **Diet Type**: vegetarian, meat, seafood, gluten-free, mediterranean
- **Supplemental**: quick (<30min), healthy, cook method (grill/stovetop/oven/InstantPot/air fryer), custom user-defined

**Prominence Index & Search**:
- Ingredient prominence: appears in title OR large quantity (≥4 bulbs garlic, ≥1 cup vegetable)
- Two-tier search: Index search (prominent ingredients first) + General search (all matches)
- Metadata tracking: Cookbook title, author, source - all searchable
- Hard-coded ingredient categorization (Salmon → Fish → Seafood) for effective filtering

### 3. Calendar & Event-Based Meal Planning
**Calendar Interface**:
- Dedicated Calendar View tab in bottom navigation
- Simple meal blocks: "[meal type]: [recipe name]"
- Event creation with guest tracking (adults/kids), dietary restrictions
- Visual distinction between simple meals and events

**Recipe Scaling Logic**:
- Display original yield, allow scaling in 0.5 increments
- Dynamic scaling: Event Group Size ÷ Recipe Yield = Scale Factor
- Non-standard fraction display: "[fraction] (rounds to [common measurement])"
- Rounding to common utensils (1/8 tsp, 1/4 cup)

**Calendar Export**:
- Export events to native device calendar (title, start time)
- Shopping day markers with push notification reminders

### 4. Smart Grocery List & Inventory System
**List Generation**:
- Date range selection from calendar → aggregate all scaled ingredients
- Split into "Pantry Items" (inside aisles: spices, oils, flour) vs "To-Buy Items"
- Unit conversion to standard metric → common packaging sizes

**Pantry Logic & Waste Reduction**:
- Inventory prompting with shopping day notifications
- Packaging conversion with "best guess" logic (6 cups stock → 2 quart containers)
- Excess tracking: "Need 6 cups. Buy 2 Quarts (8 cups total, 2 cups excess)"
- Leftover ingredient suggestions linking to recipe search

**List Organization**:
- Grocery store aisle categorization (customizable in settings)
- Shopping mode with checkable items
- Manual item addition with proper aisle placement

### 5. Collaboration & Cloud Architecture
**Multi-User System**:
- Tiered access: Viewer, Modifier (edit recipes/meals), Manager (full control)
- Share via link/email invitation (all users must sign up)
- Real-time collaboration on meal calendars and grocery lists

**Data Synchronization**:
- Cloud-first architecture with offline capability
- Last-Write-Wins conflict resolution with timestamping
- Local encrypted cache for offline viewing/editing
- Auto-sync queue management when connection restored

## Architecture & Structure

- **Entry Point**: `lib/main.dart` - Main app initialization
- **Platforms**: Primary focus on iOS and Android (mobile-first design)
- **State Management**: Plan for complex state (consider Riverpod/Bloc for scalability)
- **Database**: Firebase Firestore for cloud sync and collaboration
- **Storage**: Firebase Storage for recipe images and user photos

## Development Workflows

### Building & Running
```bash
flutter run                    # Run on connected device/emulator
flutter run -d chrome         # Run on web browser
flutter run --release         # Run release build
flutter build apk            # Build Android APK
flutter build ios            # Build iOS (requires Xcode)
```

### Testing & Analysis
```bash
flutter test                  # Run widget tests (test/widget_test.dart)
flutter analyze              # Run static analysis with flutter_lints rules
dart format .                 # Format all Dart code
```

### Dependencies
```bash
flutter pub get              # Install dependencies
flutter pub upgrade          # Upgrade packages
flutter pub outdated         # Check for newer versions
```

## Code Conventions & Patterns

- **Linting**: Uses `flutter_lints ^5.0.0` with standard Flutter lint rules in `analysis_options.yaml`
- **Imports**: Standard Flutter import pattern - `package:flutter/material.dart` for Material Design
- **Widget Structure**: Follows Flutter's declarative UI pattern with `StatelessWidget`/`StatefulWidget`
- **Naming**: Uses standard Dart naming conventions (camelCase for variables, PascalCase for classes)
- **File Organization**: Single file structure currently (`main.dart`), ready for expansion into feature-based directories

## Key Configuration Files

- **`pubspec.yaml`**: Package manifest with app metadata, dependencies, and Flutter configuration
- **`analysis_options.yaml`**: Dart analyzer configuration with Flutter lint rules
- **`android/app/build.gradle.kts`**: Android build configuration (Kotlin DSL, Java 11, namespace: `com.example.yes_chef`)
- **`test/widget_test.dart`**: Example widget test for the counter functionality

## Critical Business Logic Patterns

### OCR Validation Workflow
```dart
// OCR confidence check pattern
if (ocrConfidence < 0.6) {
  showRetryPrompt("Photo too dim or blurry. Please try again.");
  return;
}
// Highlight low-confidence text in yellow, others in gray
highlightLowConfidenceText(extractedText, confidenceMap);
```

### Recipe Scaling Algorithm
```dart
// Dynamic scaling based on event guests
double calculateScaleFactor(int eventGuests, int recipeYield) {
  double rawFactor = eventGuests / recipeYield;
  return (rawFactor * 2).round() / 2.0; // Round to nearest 0.5
}
```

### Prominence Index Logic
```dart
bool isIngredientProminent(Ingredient ingredient, Recipe recipe) {
  return recipe.title.contains(ingredient.name) || 
         ingredient.quantity >= getProminenceThreshold(ingredient.type);
}
```

### Pantry vs To-Buy Classification
```dart
// Inside aisle items = pantry, everything else = to-buy
bool isPantryItem(String ingredient) {
  return PANTRY_CATEGORIES.contains(categorizeIngredient(ingredient));
  // PANTRY_CATEGORIES: spices, oils, flour, sugar, baking supplies, etc.
}
```

## Key Dependencies (Recommended)

```yaml
dependencies:
  # Core Flutter
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # State Management (Complex app state)
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9
  
  # Firebase Backend (Required for collaboration)
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.6.0
  
  # Networking & Web Scraping
  http: ^1.1.2
  html: ^0.15.4
  
  # OCR & ML (Critical features)
  google_ml_kit: ^0.16.0
  image_picker: ^1.0.4
  camera: ^0.10.5
  
  # UI Components
  table_calendar: ^3.0.9
  cached_network_image: ^3.3.1
  
  # Local Storage & Offline
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # File handling
  file_picker: ^6.1.1
  path_provider: ^2.1.1
```

## Project Structure (Recommended)

```
lib/
├── main.dart
├── app/                          # App configuration
│   ├── app.dart
│   ├── routes.dart
│   └── constants.dart
├── core/                         # Shared utilities
│   ├── constants/
│   │   ├── pantry_categories.dart
│   │   ├── packaging_database.dart
│   │   └── ingredient_categories.dart
│   ├── extensions/
│   ├── utils/
│   │   ├── ocr_validator.dart
│   │   ├── recipe_scaler.dart
│   │   └── unit_converter.dart
│   └── services/
│       ├── notification_service.dart
│       └── sync_service.dart
├── features/                     # Feature-based architecture
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── recipe_import/
│   │   ├── data/
│   │   │   ├── ocr_service.dart
│   │   │   └── web_scraper.dart
│   │   ├── domain/
│   │   │   ├── recipe_entity.dart
│   │   │   └── import_validation.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── url_import_screen.dart
│   │       │   ├── ocr_review_screen.dart
│   │       │   └── final_confirmation_screen.dart
│   │       └── widgets/
│   ├── tagging/
│   │   ├── data/
│   │   │   └── tag_rules_repository.dart
│   │   ├── domain/
│   │   │   ├── tag_entity.dart
│   │   │   ├── prominence_calculator.dart
│   │   │   └── auto_tagger.dart
│   │   └── presentation/
│   │       └── tag_proposal_screen.dart
│   ├── meal_planning/
│   │   ├── data/
│   │   │   └── calendar_repository.dart
│   │   ├── domain/
│   │   │   ├── event_entity.dart
│   │   │   ├── meal_block_entity.dart
│   │   │   └── scaling_logic.dart
│   │   └── presentation/
│   │       ├── calendar_view.dart
│   │       └── event_creation_screen.dart
│   ├── grocery_lists/
│   │   ├── data/
│   │   │   ├── packaging_converter.dart
│   │   │   └── pantry_checker.dart
│   │   ├── domain/
│   │   │   ├── grocery_item_entity.dart
│   │   │   ├── inventory_logic.dart
│   │   │   └── waste_calculator.dart
│   │   └── presentation/
│   │       ├── grocery_list_screen.dart
│   │       └── shopping_mode_screen.dart
│   ├── collaboration/
│   │   ├── data/
│   │   │   └── sharing_repository.dart
│   │   ├── domain/
│   │   │   ├── access_control.dart
│   │   │   └── sync_conflict_resolver.dart
│   │   └── presentation/
│   └── search/
│       ├── data/
│       │   └── search_index.dart
│       ├── domain/
│       │   ├── search_algorithms.dart
│       │   └── filtering_logic.dart
│       └── presentation/
└── shared/                       # Shared UI components
    ├── widgets/
    │   ├── confidence_highlighter.dart
    │   ├── recipe_card.dart
    │   └── scaling_input.dart
    └── theme/
```

## Development Workflow

- **Design Reference**: Figma prototype available at provided link
- **Client Reviews**: Weekly demos and iterative feedback
- **Delivery Timeline**: 20-25 days including testing and deployment
- **Weekly Milestones**: Show progress with working demos each week
- **Source Code**: Full source code delivery included in project scope

## Development Notes

- **Hot Reload**: Fully supported for rapid iteration
- **Package Name**: Update `com.example.yes_chef` to production package name
- **Design System**: Follow Figma prototype closely for UI/UX consistency
- **Testing Strategy**: Comprehensive widget and integration testing required
- **Platform Deployment**: App Store and Google Play submission included
- **Analytics**: Consider AppsFlyer integration for growth tracking

## Client Collaboration Notes

- **Client**: Bailey Bennett (responsive and collaborative on copy/text)
- **Communication**: Regular updates and milestone reviews expected
- **Future Features**: Client anticipates feature requests as usage grows
- **Long-term Support**: Ongoing maintenance and feature development planned