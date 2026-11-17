# NatureVital Skeuomorphic Health Tracker (Flutter)

A native Android port of the skeuomorphic health tracking application, featuring
Clean Architecture, Google SSO (Firebase Auth), Gemini AI vision analysis, and
**local-first SQLite storage**.

## Storage model

- **Data**: SQLite (`naturevital.db`) on the device — schema lives in
  `assets/sql/schema_v1.sql` and is executed by
  `lib/data/local/app_database.dart`. No ORM, plain SQL.
- **Photos**: JPEG files under the app documents directory (`photos/`); the
  database only stores the file name.
- **Auth**: Firebase Auth (Google Sign-In) only. There is no Firestore.
- **Backup**: Settings → Export/Import a self-contained JSON file
  (profile + logs + photos). Local-only data is lost on uninstall unless
  exported.

## Setup & Configuration

1. Copy `.env.example` to `.env`:
   ```sh
   cp .env.example .env
   ```
2. Fill in your Firebase credentials and Gemini API key inside `.env`
   (`GOOGLE_SERVER_CLIENT_ID` is required for Google Sign-In).
3. Place your `google-services.json` in `android/app/google-services.json`.
4. The app reads configuration from `.env` only; `--dart-define` values in
   `scripts/run.ps1` / `config/dart_defines.example.json` are not read.

## Running the App

```sh
flutter pub get
flutter run
```

## Tests

```sh
flutter test
```

`test/data/sqlite_repositories_test.dart` runs the real schema against an
in-memory SQLite database (via `sqflite_common_ffi`) and covers log mapping,
per-user scoping, photo cleanup on delete, and goal updates.
