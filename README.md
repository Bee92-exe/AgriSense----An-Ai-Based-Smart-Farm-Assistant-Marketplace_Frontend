# AgriSense — Frontend

**A Bangla-first AI farming companion for marginal farmers in Bangladesh.**

![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.11.4-0175C2?logo=dart&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-4B5563)
![Localization](https://img.shields.io/badge/Localization-Bangla%20%2B%20English-0F6E56)

> **This repository is the Flutter client only.**
> The REST API lives in a separate repository:
> [`AgriSense----An-Ai-Based-Smart-Farm-Assistant-Marketplace_Backend`](https://github.com/Bee92-exe/AgriSense----An-Ai-Based-Smart-Farm-Assistant-Marketplace_Backend)
> Nothing in this repo runs a server — it talks to that API over HTTP.

---

## Table of contents

- [What it is](#what-it-is)
- [Features by role](#features-by-role)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Getting started](#getting-started)
- [Configuration](#configuration)
- [Backend API surface](#backend-api-surface)
- [Localization](#localization)
- [Offline behaviour](#offline-behaviour)
- [Accessibility](#accessibility)
- [Testing](#testing)
- [Building for release](#building-for-release)
- [Git workflow](#git-workflow)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## What it is

AgriSense puts agronomic advice in a farmer's hands in the language they actually
read. A farmer photographs a sick crop and gets a diagnosis; asks a question out
loud and hears an answer; receives soil- and weather-aware crop recommendations;
and can buy the exact seed, fertiliser or medicine the advice calls for from
licensed vendors in a verified marketplace — without leaving the app.

Four roles share **one binary**. Only the shell, the routes and the permissions
differ:

| Role | What they see |
|---|---|
| `farmer` | Diagnosis, advice, market, weather, news, assistant |
| `vendor` | Vendor desk, product catalogue, orders |
| `expert` | Approval desk, pending diagnoses, knowledge base, article publishing |
| `admin` | Platform overview, user/vendor management, catalogue, audit logs |

Vendors and experts start in `pending` status and cannot transact until an admin
approves them.

---

## Features by role

### Farmer

- **AI crop diagnosis** — capture or pick a photo, get a diagnosis with a
  confidence level, and read the safety guidance attached to it. Results are
  kept in a local history.
- **Crop advice** — recommendations derived from crop type, soil, season and
  district, plus a per-crop calendar.
- **Voice assistant** — ask questions by speech and hear answers read aloud
  (Bangla TTS), with a text fallback.
- **Haat Bazar marketplace** — browse categories and products from verified
  vendors, place orders, track them.
- **Weather & alerts** — current conditions and alert surfacing.
- **News & articles** — the latest 20 articles cached on device so the list still
  works offline.
- **Onboarding** — language selection, informed consent, then registration.

### Vendor

- Business profile and verification status.
- Product catalogue management (create, edit, publish).
- Order desk.

### Expert

- Desk of pending diagnoses awaiting a human opinion.
- Knowledge base and article authoring.
- News source suggestions.

### Admin

- Platform overview: approvals waiting, account health, queue failures.
- User and vendor management, including approve / suspend.
- Product catalogue oversight and read-only monitoring.
- Audit logs.

---

## Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter (stable channel), Dart SDK `^3.11.4` |
| State management | `flutter_riverpod` ^3.3.1 |
| Navigation | `go_router` ^18.1.0 (declarative routes + redirect guard) |
| HTTP | `http` ^1.6.0, wrapped in a single `ApiClient` |
| Token storage | `flutter_secure_storage` ^11.2.0 |
| Preferences | `shared_preferences` ^2.5.5 |
| Voice | `speech_to_text` ^7.3.0, `flutter_tts` ^4.2.5, `audioplayers` ^6.8.1 |
| Media | `image_picker` ^1.2.1 |
| Connectivity | `connectivity_plus` ^7.3.2 |
| Formatting | `intl` ^0.20.2 |
| Motion | `animate_do` ^4.2.0 |
| Lints | `flutter_lints` |

**No code generation.** Models are hand-written `fromJson`/`toJson` — there is no
`build_runner` step, so a fresh clone runs without generating anything.

---

## Project structure

```
lib/
├── main.dart                 # Boot: prefs + locale data, then runApp
├── app.dart                  # Root widget, theme + locale wiring
├── core/
│   ├── providers/            # App-wide Riverpod providers (settings, session)
│   ├── router/               # go_router config, Routes constants, redirect guard
│   ├── storage/              # Preference and secure-storage helpers
│   ├── theme/                # Palette, typography, scroll behaviour
│   ├── utils/                # Formatters, validators, helpers
│   ├── voice/                # Speech-to-text / TTS orchestration
│   └── widgets/              # Shared widgets (loading, empty, error states)
├── data/
│   ├── models/               # User, product, diagnosis, article, enums…
│   ├── remote/               # ApiClient, token store, per-domain repositories
│   ├── repositories/         # Domain interfaces the UI depends on
│   ├── local/                # Offline diagnosis queue and pending store
│   ├── mock/                 # Seeded fake repositories for demos and tests
│   └── reference/            # Static reference data (districts, seasons, soils)
├── features/                 # One folder per feature area
│   ├── admin/  advisory/  assistant/  auth/  crop_advice/
│   ├── diagnosis/  expert/  home/  market/  news/
│   ├── onboarding/  profile/  staff/  vendor/  voice/  weather/
├── l10n/                     # Bangla + English ARB files and generated classes
└── shell/                    # Role-aware navigation shell
```

**Layering rule:** `features/` never touches `ApiClient` directly. A feature
depends on a repository interface from `data/repositories/`, which is bound to
either a remote or a mock implementation. That is what makes the mock mode and
the widget tests possible.

---

## Getting started

### Prerequisites

- Flutter on the **stable** channel with Dart `>= 3.11.4`
  (`flutter --version` to check)
- Android Studio or Xcode for a device/emulator, or Chrome for the web target
- The backend running locally, or a reachable API URL

### Run it

```bash
git clone https://github.com/Bee92-exe/AgriSense----An-Ai-Based-Smart-Farm-Assistant-Marketplace_Frontend.git
cd AgriSense----An-Ai-Based-Smart-Farm-Assistant-Marketplace_Frontend

flutter pub get
flutter run
```

Out of the box the app points at `localhost:3000` — which is exactly right for a
backend running on your machine, **except** from an Android emulator, which
reaches the host at `10.0.2.2`. That default is already handled:

| Target | Default base URL |
|---|---|
| Android emulator | `http://10.0.2.2:3000/api` |
| iOS simulator, desktop, web | `http://127.0.0.1:3000/api` |

To point somewhere else — a real device on your LAN, or a deployed API:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_LAN_IP:3000/api
```

---

## Configuration

All configuration is compile-time via `--dart-define`. There is no `.env` file
and no secrets in this repository.

| Define | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | platform-dependent (see above) | REST base URL, including the `/api` suffix |

A physical phone cannot reach your laptop's `127.0.0.1`. Use the LAN IP, and make
sure the backend binds to `0.0.0.0`, not `localhost`.

---

## Backend API surface

The client consumes these endpoint groups. Full contracts belong to the backend
repository.

| Group | Endpoints |
|---|---|
| Auth | `/auth/login`, `/auth/register`, `/auth/logout`, `/auth/password/forgot`, `/auth/password/reset`, `/auth/refresh` |
| Profile | `/users/me` |
| Reference | `/meta/districts`, `/meta/seasons`, `/meta/soil-types` |
| Crops | `/crops/recommend`, `/crops/recommendations`, `/calendar` |
| Diagnosis | `/diagnosis/scan`, `/diagnosis/history` |
| Market | `/products`, `/products/categories`, `/orders` |
| Content | `/articles`, `/news`, `/questions` |
| Expert | `/expert/desk`, `/expert/diagnoses/pending`, `/expert/knowledge`, `/expert/articles`, `/expert/news`, `/expert/sources/suggest` |
| Vendor | `/vendor/business`, `/vendor/products`, `/vendor/desk` |
| Admin | `/admin/overview`, `/admin/users`, `/admin/vendors`, `/admin/products`, `/admin/logs` |
| Voice | `/voice/ask`, `/voice/interpret` |
| Weather | `/weather`, `/weather/alerts` |

Access tokens are held in secure storage and refreshed by `ApiClient`; a failed
refresh drops the session and the router guard sends the user back to `/login`.

---

## Localization

**Bangla is the template locale, not English.** Every key is authored in
`app_bn.arb` first, and `app_en.arb` is the translation — because Bangla is what
a farmer sees by default.

```
lib/l10n/
├── app_bn.arb     # template — source of truth
├── app_en.arb     # translation
└── app_localizations*.dart   # generated, committed
```

To add a string: add the key to `app_bn.arb`, then to `app_en.arb`, then
regenerate:

```bash
flutter gen-l10n
```

Strings are never hardcoded in widgets. The generated classes are committed to
the repo, so CI and fresh clones do not need to generate them.

---

## Offline behaviour

The app is built for intermittent connectivity, not just the happy path.

- **Diagnosis queue** — a photo taken offline is stored durably and uploaded the
  next time the app launches with a connection. Failures are swallowed by
  design: the farmer never asked for that upload, so it must not surface as an
  error on the home screen.
- **News cache** — the newest 20 articles are kept on device.
- **Connectivity awareness** — `connectivity_plus` drives retry and the offline
  indicators.
- **Riverpod async states** — every screen renders explicit loading, empty and
  failure states. A failed queue and an empty queue are visually distinct; that
  distinction is deliberate and covered by tests.

---

## Accessibility

- **High-contrast mode** toggles the entire palette at runtime, not per-widget.
- **Bangla typography** ships with HindSiliguri (Regular, Medium, SemiBold, Bold)
  bundled in `assets/fonts`, so rendering does not depend on a system font.
- **Read-aloud** text is available for advice and diagnosis results.
- Contrast and layout-overflow regressions are guarded by dedicated tests
  (`theme_contrast_test.dart`, `layout_overflow_test.dart`).

---

## Testing

```bash
flutter test          # full suite
flutter analyze       # lints (flutter_lints)
```

17 test files cover the risky parts rather than chasing coverage numbers:
diagnosis safety rules, confidence levels, the offline queue, voice agent
behaviour, contrast, layout overflow, and the staff/admin screens.

---

## Building for release

```bash
# Android App Bundle (Play Store)
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-api.example.com/api

# Android APK
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.example.com/api

# Web
flutter build web --release --dart-define=API_BASE_URL=https://your-api.example.com/api
```

Android signing material (`*.jks`, `*.keystore`, `key.properties`,
`local.properties`) is gitignored and must never be committed.

---

## Git workflow

- `main` is the only long-lived branch and always deploys.
- Commit locally, then push — **do not edit files on github.com**. Web commits
  are invisible to your local clone and produce divergent history that has to be
  force-pushed to untangle.
- Pull before you start work:

```bash
git pull
git add -A && git commit -m "what changed"
git push
```

- Use `git push --force-with-lease` (never bare `--force`) if you must rewrite
  published history on your own branch.
- Keep build output out of git. `build/` and `.dart_tool/` are already ignored;
  a healthy commit touches `lib/`, `test/`, `assets/` or config only.

---

## Troubleshooting

**`Failed to connect to github.com:443 via proxy 127.0.0.1`**
Git is routing through a local proxy that is not running. Bypass it for GitHub:

```bash
git config --global http.https://github.com.proxy ""
```

**App cannot reach the backend from the Android emulator**
`127.0.0.1` inside an emulator is the emulator itself. Use `10.0.2.2` (the
default already handles this), or your machine's LAN IP for a physical device.

**`flutter pub get` fails on the SDK constraint**
The project requires Dart `>= 3.11.4`. Run `flutter upgrade` on the stable
channel.

**Bangla text renders as boxes**
`assets/fonts` must be present and declared in `pubspec.yaml`. Do not remove the
font declarations.

---

## License

No license has been declared for this repository yet. Until one is added, all
rights are reserved by the author — do not redistribute or reuse without
permission.
