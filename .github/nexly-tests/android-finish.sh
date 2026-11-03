#!/usr/bin/env bash
set -x
EV="$GITHUB_WORKSPACE/evidence"; PKG=com.carriez.flutter_hbb
fail(){ echo "FAIL: $*" | tee -a "$EV/result.log"; exit 1; }
adb logcat -d > "$EV/logcat-full.log"
if grep -E "FATAL EXCEPTION|AndroidRuntime: Process: $PKG|Fatal signal" "$EV/logcat-full.log" > "$EV/crash.log"; then fail "crash in logcat"; fi
adb shell pidof $PKG || fail "process died"
adb uninstall $PKG | tee "$EV/04-uninstall.log" | grep -q Success || fail uninstall
adb shell pm list packages | grep -q "$PKG" && fail "package still present after uninstall"
adb exec-out screencap -p > "$EV/04-after-uninstall.png"
echo "ANDROID OK" | tee -a "$EV/result.log"
