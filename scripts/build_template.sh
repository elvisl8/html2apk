#!/usr/bin/env bash
# Builds the Java WebView template and copies the unsigned APK to assets/template.apk.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root/template"
# The wrapper jar is a binary and is not committed; fetch it on demand.
if [ ! -f gradle/wrapper/gradle-wrapper.jar ]; then
  curl -fsSL -o gradle/wrapper/gradle-wrapper.jar \
    https://raw.githubusercontent.com/gradle/gradle/v9.3.1/gradle/wrapper/gradle-wrapper.jar
fi
./gradlew --no-daemon assembleRelease
mkdir -p "$root/assets"
cp app/build/outputs/apk/release/app-release-unsigned.apk "$root/assets/template.apk"
