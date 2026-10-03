# MCSOS Mobile

Flutter mobile client for the **MCSOS** medical center / clinic management system.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.3-0175C2?logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)

## Overview

MCSOS Mobile is the mobile companion of the MCSOS clinic system. It talks to the
MCSOS backend API, keeps the user signed in, and supports Arabic (RTL) with the
same Cairo typography used on the website.

<!-- TODO: add 3-5 screenshots here, e.g. ![Login](docs/screenshots/login.png) -->

## Features

<!-- TODO: edit this list to match what the app actually does -->
- Secure sign in with token-based authentication
- Persistent session (token and user saved locally)
- Arabic localization with RTL support and Arabic date formatting
- Clean state management with Cubit

## Tech Stack

| Area | Package |
| --- | --- |
| Framework | Flutter (Dart SDK `>=3.3.0 <4.0.0`) |
| State management | `flutter_bloc` (Cubit only), `equatable` |
| Networking | `dio` |
| Local storage | `shared_preferences` |
| UI | `google_fonts` (Cairo), `cupertino_icons` |
| i18n / dates | `flutter_localizations`, `intl` |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.19 or newer
- Android Studio or VS Code with the Flutter extension
- An Android emulator or a physical device
- A running instance of the MCSOS backend API

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Amratef0/Medical_Center_MobileApp.git
cd Medical_Center_MobileApp

# 2. Install dependencies
flutter pub get

# 3. Check your environment
flutter doctor

# 4. Run the app
flutter run
```

### Configuration

<!-- TODO: replace with the real file/constant name where the base URL lives -->
Set the backend API base URL in the Dio client configuration (inside `lib/`)
before running the app.

| Environment | Base URL |
| --- | --- |
| Android emulator (backend on your PC) | `http://10.0.2.2:<PORT>/api` |
| Physical device (same Wi-Fi) | `http://<YOUR_PC_IP>:<PORT>/api` |
| Production | `https://<YOUR_DOMAIN>/api` |

> `localhost` does not work from the Android emulator. Use `10.0.2.2` instead.

## Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

The output is generated at `build/app/outputs/flutter-apk/`.

## Project Structure

```
.
├── android/            # Android platform project
├── lib/                # App source code (Dart)
├── test/               # Unit and widget tests
├── pubspec.yaml        # Dependencies and app metadata
└── analysis_options.yaml
```

## Testing

```bash
flutter test
```

## Related

- MCSOS backend API and web dashboard: <!-- TODO: add link to the backend repo -->

## Author

**Amr Atef** - [@Amratef0](https://github.com/Amratef0)

## License

<!-- TODO: choose a license (MIT is common) or remove this section -->
This project is currently unlicensed. All rights reserved.
