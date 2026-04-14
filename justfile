# list all available commands
help:
    @just -l --unsorted

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

debug_apk := "app/build/outputs/apk/debug/app-debug.apk"
release_unsigned_apk := "app/build/outputs/apk/release/app-release-unsigned.apk"
release_signed_apk := "app/build/outputs/apk/release/app-release-signed.apk"

debug:
    adb devices -l
    ./gradlew installDebug

release:
    adb devices -l
    ./gradlew assembleRelease
    rm -f {{release_signed_apk}}
    SDK_DIR="$$(sed -n 's/^sdk.dir=//p' local.properties)"
    BUILD_TOOLS_DIR="$$(find "$$SDK_DIR/build-tools" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)"
    "$$BUILD_TOOLS_DIR/apksigner" sign \
      --ks "$$HOME/.android/debug.keystore" \
      --ks-key-alias androiddebugkey \
      --ks-pass pass:android \
      --key-pass pass:android \
      --out {{release_signed_apk}} \
      {{release_unsigned_apk}}
    adb install -r {{release_signed_apk}}
