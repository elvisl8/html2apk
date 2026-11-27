# html2apk

[English](README.md) | [中文](README.zh-CN.md)

<img src="docs/icon.svg" alt="" width="96" align="right">

**Turn any website into an installable Android app — right in your browser. No install, no Android toolchain, no server, no account.**

html2apk builds a signed APK **on your own device**, in pure Dart, by patching a tiny WebView template. The APK is assembled and signed locally (WebCrypto on the web), so your site and your signing key never leave your machine. Give it a website URL, a folder containing `index.html`, or a single HTML file — a folder or single-file site is bundled inside the APK and works fully offline.

<!-- screenshot placeholder: docs/screenshot.png -->

## Highlights

- **Use it instantly** — the web app at https://elvisl8.github.io/html2apk/ needs no install; the newest dev build is at https://elvisl8.github.io/html2apk/dev/. The generator itself also runs as a native app on Android, iOS, Linux, Windows and macOS.
- **Three sources** — a website URL, a folder with `index.html` at its root (subfolders kept, so relative links, images and scripts keep working), or one self-contained `.html` file.
- **Truly offline** — sites from a folder or a single file are packed into the APK under `assets/site/` and load from the device, no network needed.
- **Your key, your updates** — a signing key is created on first use and stored per install. Regenerating an app with the same package ID installs as an update over the old one. Back the key up and restore it on any device.
- **Bilingual** — full Chinese and English UI with a one-tap switch in the app bar; the choice is remembered.
- **Full control** — app name, title-bar color, custom icon, fullscreen, editable package ID, plus advanced settings: screen orientation, dark mode for websites (Android 13+), hide status and navigation bars, keep screen on, loading color, external links, loading bar, offline page with Retry, reload button, pinch to zoom, desktop mode, custom user agent and app version.
- **My apps** — every generated app is remembered with its settings and icon; tap one to load it back into the form and regenerate it as an update.
- **Same APK everywhere** — the browser and the native builds produce byte-identical APKs (verified by test).
- **Behaves like a real app** — JavaScript on, links stay inside the app, the back button walks page history first, `mailto:`/`tel:` links open in the system app, and `http://` sites are allowed too.

## Download

**Web:** use it in the browser at [https://elvisl8.github.io/html2apk/](https://elvisl8.github.io/html2apk/) (newest development build: [https://elvisl8.github.io/html2apk/dev/](https://elvisl8.github.io/html2apk/dev/)).

**Apps:** grab a build from the [Releases](https://github.com/elvisl8/html2apk/releases) page (`N` is the build number):

- `html2apk-dev-N-android.apk` - Android 7.0+
- `html2apk-dev-N-linux-x64.tar.gz` - Linux (extract and run `html2apk`; the file picker needs `zenity`)
- `html2apk-dev-N-windows-x64.zip` - Windows (extract and run `html2apk.exe`)
- `html2apk-dev-N-macos.zip` - macOS (unsigned: right-click -> Open the first time)
- `html2apk-dev-N-ios-unsigned.ipa` - iOS 15+ for sideloading (AltStore, Sideloadly, ...); not on the App Store. An iPhone cannot install the APK, so use Save or Share to get it onto an Android device
- `html2apk-dev-N-web.zip` - the web app, to host yourself
- `SHA256SUMS.txt` - checksums of the files above

## Using it

Fill in the form and tap **Generate**:

- **App name** - home-screen label and title-bar text
- **Source** - pick one: **URL** - the site to show (`https://` is added if you leave it out); **Folder** - a folder containing `index.html` (subfolders are kept, so relative links, images and scripts keep working); **Single file** - one self-contained `.html` file, used as the app's page. A folder without `index.html` at its root cannot generate.
- **Color** - title-bar color
- **Icon** - an image from your gallery/files (center-cropped to a square); without one the app gets the html2apk globe icon
- **Fullscreen** - hides only the title bar; the Android status bar stays visible
- **Preview** - a live sketch of the app screen and home-screen icon (beside the form on wide screens)
- **Package** - shown as "Package: ... - tap to change". For a URL it is derived from the domain (`https://example.org` -> `org.example.html2apk`); for a folder or a single file it is derived from the app name (`My Site` -> `mysite.html2apk`). Every app needs its own ID: two apps with the same ID replace each other, so change it if you build several apps from one source.
- **Advanced settings** - screen orientation, dark mode for websites (Android 13+), hide the status and navigation bars, keep the screen on, app color while loading, open other sites in the browser, loading bar, offline page with Retry, reload button, pinch to zoom, desktop mode, custom user agent and app version

When the APK is ready:

- **Install** (Android) opens the package installer
- **Save** stores the APK wherever you choose (a download in the browser)
- **Share** (Android, iOS, macOS) sends the APK to another app

Regenerating an app with the same package ID installs as an update over the old one. The first build on the web takes a few seconds while the signing key is created.

### My apps

Every generated app is remembered under **My apps** (the grid icon in the app bar) with its settings and a small copy of its icon. Tap one to load it back into the form, change what you like and tap **Generate** again: it keeps its package ID, so the new APK installs as an update. Local files are not stored with a saved app — pick the folder or file again. Deleting an entry only removes it from the list.

### Back up your signing key

Open the key icon in the generator's app bar to see your signing key's SHA-256 fingerprint, save it with **Back up key** (a `html2apk-signing-key.json` file), or load a saved file with **Restore key**. Anyone with that file can publish updates to your apps, so keep it private. Restoring replaces the current key; apps signed with the old one can then no longer be updated in place unless you restore it again. On the web the key lives in the browser, so back it up before clearing site data.

### Web notes

- The web key is stored per browser **and** per origin. `elvisl8.github.io` is shared with other GitHub Pages apps, so clearing that site's data, or another app on the origin clearing its storage, deletes the key. Back it up.
- Open only one tab on your first visit, so two tabs do not each create a key.
- Self-hosting the web build needs HTTPS (WebCrypto requires a secure context).

### Signing key caveat

The generator creates a signing key on first use and stores it per install (shared preferences; browser storage on the web). Uninstalling or clearing the data of the generator **loses the key** unless Android's automatic backup restores it on reinstall or a new phone (it is enabled, but do not rely on it): back the key up via **Signing key** to be safe. Apps regenerated afterwards are signed with a new key, so the old version of that app must be uninstalled before the new one can be installed.

## Building from source

Requirements: Flutter 3.47.5, JDK 17-21 (newer JDKs are too new for the Android Gradle plugin) and the Android SDK (`ANDROID_HOME` set).

```bash
python3 tool/make_icons.py  # generates the app icons (needs Pillow: pip install pillow)
scripts/build_template.sh   # builds the template APK into assets/template.apk (gitignored)
flutter pub get
flutter test
flutter run                 # or: flutter build apk / ios / linux / windows / macos / web
```

The template build needs JDK 21 (`JAVA_HOME=/usr/lib/jvm/java-21-openjdk scripts/build_template.sh`); newer JDKs fail in the Android build tools.

Tests that verify generated APKs use `apksigner`, `aapt2` and `zipalign` from the newest build-tools under `$ANDROID_HOME`; `flutter test --platform chrome` runs the browser-compatible tests, including the check that web and native produce byte-identical APKs. The icons are drawn by `tool/make_icons.py` (Pillow); rerun it and `scripts/build_template.sh` after changing the icon.

## Maintainer: releases and CI

Every push to `master` runs `.github/workflows/dev-release.yml`: it tests, builds Android, iOS, Linux, Windows, macOS and the web app, and publishes a prerelease `dev-N` with all files plus `SHA256SUMS.txt`. The web app of the newest dev build is deployed to https://elvisl8.github.io/html2apk/dev/.

Android version codes come from the workflow run number. Do not rename or recreate `dev-release.yml`: the counter would restart and new builds would count as downgrades.

To make a full release, run **Actions -> Release -> Run workflow** (`.github/workflows/release.yml`) with a version like `2.1.0`. It copies the files of the newest `dev-N` build (or the one you name) into a release `v2.1.0`, so it ships exactly the binaries CI tested, and republishes the web app at https://elvisl8.github.io/html2apk/. Bump `version:` in `pubspec.yaml` first so the apps report the same version. Release the newest dev build: `github.token` cannot tag an older commit whose workflow files differ from master's. One-time setup: Settings -> Pages -> Source: **GitHub Actions**; Settings -> Environments -> `github-pages` -> Deployment branches must allow `master`.

The Android APK is signed with your own key, supplied through repository secrets. Without them CI signs with a debug key (the release notes say so), and users must uninstall debug-signed builds before installing release-signed ones. Create a keystore with JDK 17-21:

```bash
keytool -genkeypair -v -keystore release.jks -keyalg RSA -keysize 4096 -validity 36500 -alias html2apk
base64 -w0 release.jks   # -> secret ANDROID_KEYSTORE_BASE64
```

Also set the secrets `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (`html2apk` above) and `ANDROID_KEY_PASSWORD`.

**Back up `release.jks`.** Losing it means users must uninstall the generator before they can update it.

For a local release build, create `android/key.properties` (gitignored) with `storeFile` (relative to `android/app`), `storePassword`, `keyAlias`, `keyPassword`; all four are required. Without the file, release builds fall back to the debug key. The macOS app is unsigned: right-click -> Open the first time. The iOS `.ipa` is unsigned too (`--no-codesign`); sideloading tools sign it with the user's own Apple ID.

## Credits and v1

Made by devilAPI with <3 - https://github.com/elvisl8/html2apk

The original v1 (edit three variables in `main.dart`, build with Gradle) lives on the `legacy` branch.
