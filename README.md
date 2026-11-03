# NatureVital Skeuomorphic Health Tracker (Flutter)

A native Android port of the skeuomorphic health tracking application, featuring Clean Architecture, Firebase Auth/Firestore integration, and Gemini AI vision analysis.

## Setup & Configuration

1. Copy `.env.example` to `.env`:
   ```sh
   cp .env.example .env
   ```
2. Fill in your Firebase and Gemini API credentials inside `.env`.
3. Place your `google-services.json` in `android/app/google-services.json`.

## Running the App

```sh
flutter pub get
flutter run
```
