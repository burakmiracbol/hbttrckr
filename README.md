# hbttrckr

An open-source habit tracker built with Flutter. The goal is to provide a free, cross‑platform app for tracking personal habits and daily progress.

## Overview

The name **hbttrckr** is derived from the consonants in “habit tracker.”

Core ideas and features (from the current implementation):

- Habit types: **task** (bool), **count** (number), **time** (duration)
- Habit grouping (currently alpha)
- Cross‑platform targets (mobile + desktop)
- Persisted settings on device
- Calendar‑based main screen and daily completion markers
- Completion‑rate tracking and updates
- Glassmorphism styling
- Daily progress tracking and skipping
- Statistics view and monthly calendar progress
- Habit level, strength, and streak features
- Material Design 3 color schemes with selectable base color
- Notifications (beta) and notification testing
- Rich‑text notes per habit
- Bottom‑sheet summaries and settings (mobile‑friendly)
- Desktop window effects (mica/transparency)

## Stack

- **Language:** Dart
- **Framework:** Flutter (Material Design 3)
- **State management:** Provider
- **Package manager:** Flutter/Dart Pub (`pubspec.yaml`)
- **Notable packages:** `shared_preferences`, `flutter_local_notifications`, `flutter_quill`, `bitsdojo_window`, `flutter_acrylic`, `image_picker`

## Note for this repo !!
This is a not-a-production-ready repo. So if you using this repo for yourself, keep in mind that you can face some bugs. Some of them are available in issues and README.md (below)

And currently this app developing in windows so maybe there are some issus with other environments (some native things)

### For Windows 
- Make sure that you are using this app with all release folder because this app needs some additional packages for native environment (don't just use with .exe )
- Sometimes you can face with deadlock (just app is freeezing) so calm down there are much deadlocks we are trying to face with them

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
