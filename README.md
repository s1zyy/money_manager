<p align="center">
  <h1 align="center">✈️ TripPace</h1>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/iOS-App_Store-000000?style=for-the-badge&logo=apple&logoColor=white"/>
  <img src="https://img.shields.io/badge/Android-Google_Play-3DDC84?style=for-the-badge&logo=googleplay&logoColor=white"/>
  <img src="https://img.shields.io/badge/License-MIT-22c55e?style=for-the-badge"/>
</p>

<p align="center">
  <b><a href="https://github.com/s1zyy/money_manager_backend">⚙️ Backend (Spring Boot)</a></b> •
  <b><a href="#architecture">Architecture</a></b> •
  <b><a href="#quick-start">Quick Start</a></b>
</p>

---

## About

**TripPace** is a trip expense-sharing app for iOS and Android. Add shared expenses on the go, split costs equally or with custom amounts, invite friends — even without an account — and settle up at the end with the minimum number of transfers.

Built from scratch with a clean Flutter architecture and a Spring Boot backend deployed on Railway.

---

## Demo

<table align="center">
  <tr>
    <th align="center">App Walkthrough</th>
    <th align="center">Adding an Expense</th>
  </tr>
  <tr>
    <td align="center">
      <img src="flutter/assets/demo.gif" width="360" alt="App walkthrough"/>
    </td>
    <td align="center">
      <img src="flutter/assets/add_expense.gif" width="360" alt="Adding an expense"/>
    </td>
  </tr>
</table>

---

## Screenshots

<table align="center">
  <tr>
    <td align="center"><img src="flutter/assets/screenshots/login.png" width="210" alt="Login"/><br/><sub>Login</sub></td>
    <td align="center"><img src="flutter/assets/screenshots/list_trips.png" width="210" alt="My Trips"/><br/><sub>My Trips</sub></td>
    <td align="center"><img src="flutter/assets/screenshots/trip_details.png" width="210" alt="Trip Details"/><br/><sub>Trip Details</sub></td>
    <td align="center"><img src="flutter/assets/screenshots/add_expense.png" width="210" alt="Add Expense"/><br/><sub>Add Expense</sub></td>
  </tr>
</table>

---

## Features

| | Feature |
|---|---|
| 🔐 | JWT authentication — register & login |
| ✈️ | Full trip lifecycle — create, update, archive, unarchive, delete |
| 🔗 | Join trips via shareable invite codes |
| 👥 | Virtual participants — invite people without an account |
| 📧 | Email invite flow — virtual participant claims a real account |
| 💰 | Expense tracking with equal or custom splits |
| 📊 | Live balance dashboard & settlement suggestions |
| 📉 | Per-participant budget & daily limit tracking |
| 🌍 | 7 languages — EN, RU, UK, DE, FR, ES, PT |
| 🛡️ | App version enforcement with automatic update screen |
| 🗑️ | Soft delete or full account deletion |
| 📱 | iOS & Android |

---

## Architecture

Clean Architecture in Flutter — each layer has one responsibility and only depends on layers closer to the domain:

```
lib/
│
├── domain/                  ← Pure Dart, zero Flutter dependencies
│   ├── entities/            # Trip, Expense, TripDashboard, AuthResult
│   ├── repositories/        # Abstract interfaces
│   └── usecases/            # One class = one operation
│       ├── auth/            # Login, Register, Logout
│       ├── trip/            # CreateTrip, JoinTrip, ArchiveTrip, InviteVirtualParticipant…
│       └── expenses/        # AddExpense, UpdateExpense, DeleteExpense…
│
├── data/                    ← Implements domain interfaces
│   ├── models/              # JSON serialization (fromJson / toJson)
│   ├── datasources/         # Dio HTTP calls + FlutterSecureStorage
│   └── repositories/        # Repository implementations
│
├── presentation/            ← UI layer
│   ├── pages/               # LoginPage, MainPage, TripDetailsPage, SettlementPage…
│   └── providers/           # AuthProvider, TripsProvider, TripDashboardProvider
│
├── core/                    ← Shared infrastructure
│   ├── dio_client.dart      # Base URL, timeout config
│   ├── auth_interceptor.dart
│   ├── app_version_interceptor.dart
│   └── utils/               # Overlay notifications, date helpers
│
└── injection_container.dart  ← GetIt DI wiring (all registrations in one place)
```

**Key decisions:**
- **GetIt** for dependency injection — `sl<T>()` anywhere, no `BuildContext` threading
- **Provider** (`ChangeNotifier`) for UI state — `AuthProvider` and `TripsProvider` are lazy singletons, `TripDashboardProvider` is a factory (new instance per trip)
- **AuthInterceptor** auto-attaches JWT from `FlutterSecureStorage` to every request
- **AppVersionInterceptor** adds `X-App-Version` header — backend rejects outdated clients
- All notifications use a unified `OverlayEntry` system — works above bottom sheets

---

## Tech Stack

| | Technology |
|---|---|
| Language | Dart 3 |
| Framework | Flutter 3 |
| State management | Provider + ChangeNotifier |
| Dependency injection | GetIt |
| HTTP client | Dio 5 |
| Secure storage | flutter_secure_storage |
| Localization | flutter_localizations (7 languages) |

---

## Quick Start

**Prerequisites:** Flutter SDK 3.x, running backend (see [backend repo](https://github.com/s1zyy/money_manager_backend))

```bash
# 1. Clone
git clone https://github.com/s1zyy/money_manager.git
cd money_manager/flutter

# 2. Install dependencies
flutter pub get

# 3. Run on iOS simulator (local backend)
flutter run --dart-define=BASE_URL=http://localhost:8080/api

# 4. Run on Android emulator (local backend)
flutter run --dart-define=BASE_URL=http://10.0.2.2:8080/api

# 5. Run against production
flutter run --dart-define=BASE_URL=https://trippace.up.railway.app/api
```

> If `BASE_URL` is not passed, the app defaults to `https://trippace.up.railway.app/api`.

```bash
# Static analysis
flutter analyze

# Tests
flutter test

# Regenerate localizations after editing .arb files
flutter gen-l10n
```

**Build for release:**

```bash
# Android (AAB for Google Play)
flutter build appbundle --release

# iOS (IPA for TestFlight / App Store)
flutter build ipa --release
```

---

## Pages

| Page | Description |
|---|---|
| `SplashPage` | Animated splash screen |
| `LoginPage` | Email + password login |
| `RegisterPage` | New account creation |
| `MainPage` | List of trips (Active / Upcoming / Archived) |
| `CreateTripPage` | New trip form — name, dates, budget, currency |
| `TripDetailsPage` | Expenses list, balance dashboard, participant management |
| `AddExpensePage` | Add / edit expense with equal or custom split |
| `SettlementPage` | Settle up — minimum transfer suggestions |
| `TripSettingsPage` | Trip info, participants, archive / delete |
| `EditProfilePage` | Update name, change password, delete account |
| `FeedbackPage` | Send bug report or feedback |
| `UpdateRequiredPage` | Shown when app version is outdated |

---

## Backend

This app requires the REST API from the companion backend:

**[⚙️ TripPace Backend](https://github.com/s1zyy/money_manager_backend)** — Spring Boot 4, Java 21, PostgreSQL, deployed on Railway

```
┌─────────────────────────┐
│  TripPace (this repo)    │ ◄── you are here
└────────────┬────────────┘
             │ HTTPS / REST
┌────────────▼────────────┐
│  Spring Boot (Railway)   │
└────────────┬────────────┘
             │ JDBC
┌────────────▼────────────┐
│      PostgreSQL 15       │
└─────────────────────────┘
```

---

## License

Custom License — see [LICENSE](LICENSE)
