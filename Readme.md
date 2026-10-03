# 🏥 MCSOS Mobile — Medical Center Management App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![State](https://img.shields.io/badge/State-Cubit%20(flutter__bloc)-6C63FF)
![Backend](https://img.shields.io/badge/Backend-NestJS-E0234E?logo=nestjs)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)

**MCSOS Mobile** is the Flutter mobile client of the Medical Center Management System (MCSOS). It uses the same REST APIs as the React web dashboard (NestJS backend), so accounts, roles, and data are shared across web and mobile.

The app has an Arabic-language UI with a dark theme (blue accents, **Cairo** font), matching the look and feel of the web dashboard.

---

## 📌 Table of Contents

- [Tech Stack](#-tech-stack)
- [Modules](#-modules)
- [Getting Started](#-getting-started)
- [Connecting to the Backend](#-connecting-to-the-backend)
- [Project Structure](#-project-structure)
- [Adding a New Module](#-adding-a-new-module)
- [Android Build Notes](#-android-build-notes)
- [Troubleshooting](#-troubleshooting)

---

## 🚀 Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev/) / Dart | Cross-platform mobile framework |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) (**Cubit only**) | State management — no Bloc events |
| [Dio](https://pub.dev/packages/dio) | HTTP client with interceptors |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Local token storage |
| NestJS REST API (`/api/v1`) | Backend shared with the React web app |
| JWT + automatic refresh | Authentication |
| Cairo font, dark theme | UI styling |

---

## 🧩 Modules

| Module | List | Add | Edit | Delete | Notes |
|---|:-:|:-:|:-:|:-:|---|
| **Patients** | ✅ | ✅ | ✅ | ✅ | Full detail screen: sessions, treatment plans, packages, medical history, medical documents |
| **Doctors** | ✅ | ✅ | ✅ | ✅ | Doctor availability (working hours) screen |
| **Sessions** | ✅ | ✅ | ✅ | ✅ | Filter by status; update status (attended / no-show / cancelled) by tapping a session |
| **Scheduling (Slots)** | ✅ | ✅ | ✅ | ✅ | Book / cancel a slot directly |
| **Treatment Plans** | ✅ | ✅ | – | ✅ | Add via bottom sheet |
| **Packages** | ✅ | ✅ | – | ✅ | Assign a package to a patient directly from the packages screen |
| **Finance** | ✅ | ✅ | ✅ | – | Two tabs: payments & invoices; add a payment; mark an invoice as paid |
| **Follow-ups** | ✅ | – | ✅ | ✅ | Change follow-up status |
| **Waitlist** | ✅ | ✅ | – | ✅ | |
| **Users** | ✅ | ✅ | – | ✅ | Admin only |
| **Reporting** | ✅ | – | – | – | Daily report |
| **Profile** | ✅ | – | – | – | Logout |
| **Medical history & documents** | ✅ | ✅ | ✅ | ✅ | Inside the patient detail screen (documents: add / delete only) |

**Highlights**
- Automatic token refresh via a Dio interceptor (same behavior as the web app's Axios interceptor).
- A single parser (`extractListData()`) handles both response shapes returned by the API: a plain array or `{ data, total, page, limit }`.
- Server errors are mapped to readable user-facing messages.

**Not included yet:** light mode (the app is dark-theme only).

---

## ⚙️ Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | 3.x |
| Android SDK | API 34+ (Android Studio) |
| JDK | **17 or 21** (see [Android Build Notes](#-android-build-notes)) |
| MCSOS backend | Running locally (NestJS) |

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/Amratef0/Medical_Center_MobileApp.git
cd Medical_Center_MobileApp

# 2. Install dependencies
flutter pub get

# 3. Check your environment
flutter doctor -v

# 4. Run the app
flutter run
```

If you have more than one device or emulator:

```bash
flutter devices
flutter run -d <device_id>
```

> **If the `android/` folder is missing** (it is generated, not hand-written), create it once. This only adds the platform folders and does not modify `lib/` or `pubspec.yaml`:
>
> ```bash
> flutter create . --platforms=android --org com.mcsos
> ```
>
> Then apply the settings in [Android Build Notes](#-android-build-notes).

If `flutter doctor` reports missing Android licenses:

```bash
flutter doctor --android-licenses
```

---

## 🔌 Connecting to the Backend

The API address lives in one place: **`lib/core/constants/app_constants.dart`**

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

| Where the app runs | Base URL |
|---|---|
| Android emulator | `http://10.0.2.2:3000/api/v1` |
| iOS simulator | `http://localhost:3000/api/v1` |
| Physical device (same Wi-Fi) | `http://<your-computer-ip>:3000/api/v1` |

- `10.0.2.2` is the Android emulator's alias for the host machine's `localhost`.
- On a physical device, use your computer's local IP (`ipconfig` on Windows, `ifconfig` on macOS/Linux).
- If the backend runs on another port, change `3000` accordingly.
- After changing the URL, restart the app with `flutter run` (hot reload may not pick it up).

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/app_constants.dart       Backend URL + storage keys
│   ├── network/
│   │   ├── api_client.dart                Dio + auth token + automatic refresh
│   │   ├── api_error.dart                 Maps server errors to readable messages
│   │   └── list_response_parser.dart      Extracts lists (array or { data, ... })
│   ├── storage/token_storage.dart         Local token storage (SharedPreferences)
│   ├── theme/                             Colors and app theme
│   ├── utils/                             Date formatting, enum translations, dialogs
│   └── widgets/                           Shared widgets (Loading / Error / Empty / Badge / Drawer ...)
├── models/                                One class per entity (fromJson)
├── repositories/                          One repository per backend endpoint (Dio calls)
├── cubits/                                One Cubit per screen or group of screens
├── screens/                               Screens, one folder per module
├── routes/app_routes.dart                 Route names and navigation
└── main.dart                              App entry point
```

**Data flow**

```
Screen (BlocBuilder) → Cubit → Repository → ApiClient (Dio) → NestJS API
```

---

## ➕ Adding a New Module

Follow the same pattern used by the existing modules:

1. **Model** — `lib/models/xxx_model.dart`: fields + `fromJson`.
2. **Repository** — `lib/repositories/xxx_repository.dart`: functions that call `ApiClient().dio`.
3. **Cubit** — `lib/cubits/xxx_cubit.dart`: a state class (status / data / error) + a Cubit using the repository.
4. **Screen** — `lib/screens/xxx/xxx_list_screen.dart`: `BlocProvider` + `BlocBuilder`.
5. **Route** — register it in `lib/routes/app_routes.dart`.
6. **Drawer** — add a tab in `lib/core/widgets/main_drawer.dart`.

If an endpoint changes in the backend, update only that module's repository file.

---

## 🤖 Android Build Notes

Verified on an Android emulator (Pixel 9 Pro) with **JDK 21** and **Gradle 8.14.5**. Newer JDKs (e.g. 25) can break the Gradle/AGP toolchain, so use JDK 17 or 21.

**1. Point Flutter at JDK 21**

```powershell
flutter config --jdk-dir="C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot"
```

**2. Gradle wrapper** — `android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14.5-bin.zip
```

**3. Plugin versions** — `android/build.gradle.kts` (the root one, not `app/`):

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}
```

AGP 8.11.x with Kotlin 2.2.x is pinned on purpose: AGP 9.x (the default generated by newer `flutter create`) conflicts with some plugins such as `file_picker`.

**4. Release build type** — `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        isMinifyEnabled = true
        isShrinkResources = true
    }
}
```

After any change:

```bash
flutter clean
flutter pub get
flutter run
```

> If you delete `android/` and run `flutter create .` again, these settings are reset and must be re-applied.

---

## 🛠️ Troubleshooting

**Cannot reach the API**
- Make sure the backend is running (`npm run start:dev` in the backend folder).
- Check `baseUrl` in `app_constants.dart` (see [Connecting to the Backend](#-connecting-to-the-backend)).
- Call the same URL from Postman or Insomnia to confirm the backend responds.
- Read the `flutter run` terminal output: Dio logs the failed request in detail.

**Gradle / AGP / Kotlin / Java errors**

```bash
flutter clean
flutter pub get
cd android && ./gradlew --version && cd ..
flutter run -v
```

If Gradle picks the wrong JDK, set it explicitly in `android/gradle.properties`:

```properties
org.gradle.java.home=C:/Program Files/Java/jdk-21
```

---

## 👤 Author

**Amr Atef** — [@Amratef0](https://github.com/Amratef0)
