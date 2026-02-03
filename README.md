# hbttrckr

An open-source habit tracker built with Flutter. The goal is to provide a free, cross‑platform app for tracking personal habits and daily progress.

## Overview

The name **hbttrckr** is derived from the consonants in “habit tracker.”

Core ideas and features (from the current implementation):

- Habit types: **task** (bool), **count** (number), **time** (duration)
- Habit grouping (currently alpha)
- Sign-in w/ Google in multi-platform (currently not working for linux because of firebase_auth is not compatible with Linux)
- Cross‑platform targets (mobile + desktop)
- Persisted settings on device
- Calendar‑based main screen and daily completion markers
- Completion‑rate tracking and updates
- Glassmorphism styling
- Glowing effects for attractive visual style
- Capsule style for highlighting the important infos and actions
- Daily progress tracking and skipping
- Statistics view and monthly calendar progress
- Habit level, strength, and streak features
- selectable color scheme styles with base color
- Material Adaptive Design integrated (currently beta)
- Material Design 3 following principle for now (in future every platform has their style and design so for example iOS -> LiquidGlass)
- Notifications (beta) and notification testing
- Rich‑text notes per habit
- Bottom‑sheet summaries and settings (mobile‑friendly)
- Desktop window effects (mica/transparency)

ideas and features that under development: 

- Universalness in design : You can choose you app design style if you want
  - some main design styles are the following ones : JOMC (our design style), Material 3, Cupertino, Fluent, Yaru (Ubuntu's style) and macOS
  - it's still under development but you can see how it works for now you can check by style_provider.dart and when you change please hot restart the application to see the result
    (for now it only works for actions sheets like when you press settings icon on main page)
  - what is under development with this feature is: Main app styles changing by settings (for example we are using material design for phones when you change that you can see app like fluent design and much more),
  differencing the main app style and in app style, changing by settings (not only design but maybe view types also)
  , opening screen for new users to choose their theme configurations
  

## Stack

- **Language:** Dart
- **Framework:** Flutter (Material Design 3)
- **State management:** Provider
- **Package manager:** Flutter/Dart Pub (`pubspec.yaml`)
- **Notable packages:** `shared_preferences`, `flutter_local_notifications`, `flutter_quill`, `bitsdojo_window`, `flutter_acrylic`, `image_picker`

## Note for this repo !!
This is a not-a-production-ready repo. So if you using this repo for yourself, keep in mind that you can face some bugs. Some of them are available in issues and README.md (below)

And currently this app developing in windows (for tablets and mobile phones other platforms will be covered soon) so maybe there are some issus with other environments (some native things u know)

### For Windows 
- Make sure that you are using this app with all release folder because this app needs some additional packages for native environment (don't just use with .exe )
- Sometimes you can face with deadlock (just app is freeezing) so calm down there are much deadlocks we are trying to face with them (sadly)

## Entry Points

- `lib/main.dart` (app entry point)

## Requirements

- Flutter SDK (Dart SDK constraint in `pubspec.yaml`: `sdk: ^3.9.0`)
- Platform toolchains as required by Flutter (Android SDK, Xcode for iOS/macOS, Visual Studio Build Tools for Windows, etc.)
  - TODO: Confirm exact toolchain versions used in development.

## Setup

```bash
git clone <repo-url>
cd hbttrckr
flutter pub get
```

## Run

```bash
flutter run
```

To target a specific platform/device:

```bash
flutter devices
flutter run -d <device-id>
```

## Scripts / Common Commands

This repo does not define custom scripts; use standard Flutter commands:

| Task | Command |
| --- | --- |
| Install dependencies | `flutter pub get` |
| Run the app | `flutter run` |
| Run tests | `flutter test` |
| Build (example) | `flutter build <platform>` |

## Environment Variables

No required environment variables are documented in the repo.

- TODO: Document any runtime configuration (API keys, notification config, etc.) if/when added.

## Tests

Tests are located in `test/`.

```bash
flutter test
```

## Project Structure

```text
lib/                # App source (providers, views, services, sheets, classes)
assets/             # App assets (e.g., animations)
test/               # Flutter tests
android/ ios/       # Mobile platform projects
windows/ macos/     # Desktop platform projects
linux/ web/         # Desktop and web targets
```

## License

This project is licensed under the **GNU GPL v3**. See [LICENSE](./LICENSE).

## Contributing

Issues, PRs, and suggestions are welcome. You can also help by addressing TODOs in the codebase (for example in `lib/views/mainappview.dart`).

(don't tryna use my api keys for bad things you only gonna hurt yourself and waste time)