# CarryMate

Robot helper companion app with human-following tracking, remote manual control, and cart monitoring.

## Getting Started

## Features

- Onboarding flow and simple login form (no backend yet).
- Home tab showing battery progress, range to user, real carried weight, and health status widgets.
- Remote screen supporting Manual / Automatic mode (camera preview placeholder).
- Functional Cart tab: list of sample carts with live battery %, range and weight; tap to select; refresh randomizes data (replace later with Firestore).
- Functional Profile tab: edit display name, view email, live steps & calories counters and quick action shortcuts; simulate step increments; logout returns to login screen.
- Widget tests for Cart and Profile tabs.

## Run

```powershell
flutter pub get
flutter test               # run widget tests
flutter run                # launch app on device/emulator
```

## Next Steps

- Integrate Firebase Auth & Firestore (uncomment initialization in `main.dart`).
- Replace fake repositories with real-time streams.
- Connect remote control buttons to robot hardware APIs.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
