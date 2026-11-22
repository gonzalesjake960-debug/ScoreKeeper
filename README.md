# CourtScore — Flutter Score Keeper

A simple, polished two-team score keeper built with Flutter and Material 3.

## Features

- Two editable team names
- Add points (+1, +2, +3) and subtract points (-1)
- Undo the most recent score change
- Reset both scores with confirmation
- Quick match presets (First to 11, 21, or 30)
- Match progress indicator and winning-state highlight
- Responsive layout for phones and larger screens
- No third-party runtime packages

## Run locally

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Clone this repository:
   ```bash
   git clone https://github.com/YOUR-USERNAME/courtscore.git
   cd courtscore
   ```
3. Fetch packages and run:
   ```bash
   flutter pub get
   flutter run
   ```

## Upload to GitHub

Create an empty repository on GitHub, then run these commands in this folder:

```bash
git init
git add .
git commit -m "Initial CourtScore Flutter app"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/courtscore.git
git push -u origin main
```

Replace `YOUR-USERNAME` and `courtscore` with your GitHub username and repository name.

## Build

```bash
flutter build apk --release
```

For web:

```bash
flutter build web --release
```

## FlutterFlow note

This download is a standard Flutter source-code project that is ready to push to GitHub. It is **not** a native FlutterFlow editor project file. FlutterFlow's GitHub integration works with a project created/exported from FlutterFlow; use this app as a code reference or recreate its UI and logic in FlutterFlow. Custom Flutter files are not automatically importable as an editable FlutterFlow visual project.

## Project structure

```text
courtscore/
├── lib/
│   └── main.dart
├── test/
│   └── widget_test.dart
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
└── README.md
```
