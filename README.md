# Shop Manager — Working Progress

Offline-first Flutter app for small shops in Bangladesh.  
Built from the UI/UX PDF in `UI/Shop_Manager_UIUX.pptx.pdf`.

---

## Status

| Area | Status |
|------|--------|
| UI screens from PDF | Done |
| Offline SQLite storage | Done |
| Sales / stock / dues / expenses / reports | Done |
| Bangla + English copy | Done |
| Frontend flow (no login) | Done |
| Clean layered architecture | Done |
| Analyzer + widget test | Passing |
| Cloud sync / real OTP auth | Not started |
| Category-filtered product browse | Not started |

---

## What was built (progress log)

### 1. UI from PDF
- Splash (branding: Small Business / Small Store Management System)
- Onboarding (Monitor → Next)
- Language (বাংলা / English)
- Shop setup (name + type)
- Main tabs: হোম · বিক্রি · পণ্য · বাকি · আরও
- Quick Sell (code search, qty, flexible price, cash/due)
- Products list + Add Product
- Due book + Payment collection
- Expense, Daily report, Low stock, Settings
- Orange numbered **tap hints** on key screens (demo guide)

### 2. Functionality (offline)
- Local DB: `shop_manager.db` (sqflite)
- Persist settings (onboarding, language, shop)
- Seed demo products + sample dues on first run
- Complete sale → reduce stock; due sale → customer due
- Collect payment → reduce due
- Add product / expense
- Daily report by date; low-stock list
- Home shows today’s sales + due totals

### 3. Auth decision
- Sign In / Sign Up / OTP **removed** for frontend-only use
- Flow starts after language → shop setup → home
- `users` table kept for a future backend login

### 4. Architecture refactor
App reorganized into clean layers:

```
lib/
  main.dart                 # Entry + desktop SQLite FFI
  app/app.dart              # MaterialApp + Provider
  core/                     # theme, l10n, widgets, constants
  domain/
    entities/               # Product, Customer, Sale, Expense, Shop, User
    repositories/           # ShopRepository (contract)
  data/
    local/app_database.dart # Schema + queries
    repositories/           # LocalShopRepository (SQLite impl)
  presentation/
    state/shop_store.dart   # UI state + business validation
    screens/                # All UI screens
```

**Dependency rule:**  
`Screens → ShopStore → ShopRepository → AppDatabase`  
Screens never import `sqflite` / `AppDatabase` directly.

### 5. Fixes along the way
- Removed `shared_preferences` (MissingPluginException) → settings in SQLite
- Fixed Navigator `_debugLocked` → root `AppGate` driven by store flags
- Restored PDF-aligned splash / onboarding / home / bottom nav
- Tap-flow + architecture notes available as Cursor canvases

---

## App flow (where to tap)

```
Splash (~1.6s)
  → Onboarding [Next]
  → Language [বাংলা/English → Next]
  → Shop Setup [name + type → এখনই শুরু করুন]
  → MainShell
       হোম     → Quick Sell banner / category tiles
       বিক্রি   → code → qty/price → নগদ|বাকি → বিক্রি সম্পন্ন
       পণ্য    → search / add product / tap row → sell
       বাকি    → টাকা আদায় → save payment
       আরও     → Report / Expense / Low stock / Settings
```

### Demo product codes
| Code | Product |
|------|---------|
| `TS001-L` | টি-শার্ট |
| `CH05` | চার্জার |
| `RC010` | চাল 5kg |

---

## Database (SQLite)

| Table | Purpose |
|-------|---------|
| `settings` | onboarding, language, optional session |
| `shop` | name, type, low_stock_threshold |
| `products` | catalog + stock |
| `customers` | due book |
| `sales` | sale lines (price, profit, cash/due) |
| `payments` | due collections |
| `expenses` | expense log |
| `users` | reserved for future auth |

---

## Business rules (implemented)

- Sell qty cannot exceed stock
- Sell price cannot go below cost price
- Due sale needs customer name + phone
- Payment cannot exceed outstanding due
- Product codes must be unique

---

## How to run

```bash
flutter pub get
flutter run
```

In Android Studio: open project → Run `main.dart`  
After folder moves: **Reload from Disk** / full restart (not hot reload only).

```bash
flutter analyze lib test
flutter test
```

---

## Design source

- Spec: `UI/Shop_Manager_UIUX.pptx.pdf`
- Principles from PDF: Bangla-first, large buttons, offline-friendly, product-code fast sale, max 1–2 taps where possible

---

## Not done / next ideas

- [ ] Real auth (phone OTP / backend)
- [ ] Cloud backup / multi-device sync
- [ ] Category filter on Home tiles
- [ ] Barcode camera scan into Quick Sell
- [ ] Separate use-case classes / feature repositories (optional)
- [ ] Hide or toggle tap-hint badges for production

---

## Quick reference — key files

| File | Role |
|------|------|
| `lib/main.dart` | App entry |
| `lib/app/app.dart` | Provider + theme |
| `lib/presentation/screens/app_gate.dart` | Root routing by state |
| `lib/presentation/state/shop_store.dart` | App state + rules |
| `lib/domain/repositories/shop_repository.dart` | Persistence contract |
| `lib/data/local/app_database.dart` | SQLite implementation |
| `UI/Shop_Manager_UIUX.pptx.pdf` | Original UI/UX design |
