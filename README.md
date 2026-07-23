# Shop Manager

Offline-first Flutter POS for small shops (Bangla / English).

## Architecture

```
lib/
  app/                 # MaterialApp + Provider wiring
  core/                # theme, l10n, shared widgets, constants
  domain/              # entities + ShopRepository contract
  data/                # SQLite (local) + LocalShopRepository
  presentation/        # ShopStore + screens
  main.dart
```

**Rule:** UI talks to `ShopStore` → `ShopRepository` → SQLite. Screens never import `sqflite` / `AppDatabase`.

## Run

```bash
flutter pub get
flutter run
```

## Flow (no login)

Splash → Onboarding → Language → Shop Setup → Home  
Tabs: হোম · বিক্রি · পণ্য · বাকি · আরও

Demo codes: `TS001-L`, `CH05`, `RC010`
