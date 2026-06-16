# 📱 Running Flappy World Cup on a phone

The Dart code is already mobile-ready (sqflite high scores persist on device,
the backend URL is configurable). You just need to (1) generate the native
platform folders, (2) allow plain HTTP to your dev backend, and (3) point the
app at your computer's IP.

---

## 1. Generate the Android/iOS projects (one time)

This repo ships only the Dart source. From `flutter_app/`, scaffold the native
folders without touching your `lib/` or `pubspec.yaml`:

```bash
cd flutter_app
flutter create .
flutter pub get
```

This creates `android/`, `ios/`, etc.

---

## 2. Start the backend so the phone can reach it

Run the backend on your computer (Docker or local). It listens on port 4000.

```bash
docker compose up -d --build db backend     # or run all three
```

Find your computer's LAN IP (phone and PC must be on the SAME Wi-Fi):

- **Windows:** `ipconfig`  → look for "IPv4 Address" (e.g. 192.168.1.20)
- **macOS:**   `ipconfig getifaddr en0`
- **Linux:**   `hostname -I`

Test it from the phone's browser: open `http://YOUR_IP:4000/health` — you
should see `{"status":"ok","db":"connected"}`.

> If it doesn't load, allow inbound port 4000 through your computer's firewall
> (Windows Defender Firewall → allow Node/Docker on private networks).

---

## 3. Allow plain HTTP (cleartext) on the device

Local dev uses `http://` (not `https://`), which Android & iOS block by default.

**Android** — copy the provided file and edit the manifest:
- Copy `mobile_setup/android/network_security_config.xml`
  → `flutter_app/android/app/src/main/res/xml/network_security_config.xml`
  (create the `xml/` folder if needed)
- Apply `mobile_setup/android/AndroidManifest.snippet.txt`
  (adds `INTERNET` permission + `usesCleartextTraffic` + `networkSecurityConfig`)

**iOS** — apply `mobile_setup/ios/Info.plist.snippet.txt`
(adds the `NSAppTransportSecurity` exception to `ios/Runner/Info.plist`)

---

## 4. Point the app at your backend & run

Plug in the phone (USB debugging on Android / trusted device on iOS), then:

```bash
flutter devices                       # confirm your phone shows up
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:4000
```

**Or skip the dart-define** and just set it inside the app: launch the app,
open **"Server (for phones)"** on the home screen, type
`http://YOUR_IP:4000`, and tap **Save**. It's remembered between launches.

---

## 5. Build an installable file (optional)

```bash
# Android APK you can copy to the phone
flutter build apk --release --dart-define=API_BASE_URL=http://YOUR_IP:4000
# -> build/app/outputs/flutter-apk/app-release.apk

# iOS needs Xcode + an Apple account to sign
flutter build ios --release --dart-define=API_BASE_URL=http://YOUR_IP:4000
```

> A release APK has a fixed server URL baked in. Since the in-app **Server**
> field overrides it at runtime, you can also build without the dart-define
> and set the address on the phone after install.

---

## Notes
- **Emulator/simulator** still works with no IP: Android emulator auto-uses
  `10.0.2.2:4000`, iOS simulator uses `localhost:4000`.
- **Local high scores** persist on phones (sqflite); the global leaderboard &
  predictions come from the backend.
- **Audio** is optional — add `jump.wav`/`score.wav`/`hit.wav` to
  `assets/audio/` and they'll play on device.
