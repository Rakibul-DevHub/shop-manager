# Shop Manager

Offline-first Flutter app for small shops (Bangla / English).

## What works

- Local SQLite database (no internet required)
- Sign up / Sign in (demo OTP: `1234`)
- Shop setup
- Quick Sell with flexible price + cash/due
- Product add / search / stock updates
- Due book + payment collection
- Expenses
- Daily sales report + profit
- Low stock alerts
- Settings (language, shop, low-stock threshold)
- Logout + session restore

## Run

```bash
flutter pub get
flutter run
```

## Demo flow

1. Onboarding → choose language
2. Set shop name + type
3. Sell with code `TS001-L`, `CH05`, or `RC010`
4. Try due sale with customer name/phone
5. Collect payment from বাকি tab
6. Check home dashboard + daily report

No login/email/OTP required (frontend-only flow).
