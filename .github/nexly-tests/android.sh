#!/usr/bin/env bash
set -x
EV="$GITHUB_WORKSPACE/evidence"; mkdir -p "$EV"; PKG=com.carriez.flutter_hbb
fail(){ echo "FAIL: $*" | tee -a "$EV/result.log"; adb exec-out screencap -p > "$EV/fail.png"; adb logcat -d > "$EV/logcat-full.log"; exit 1; }
adb logcat -c
adb install -r dist/NexlyDesk-android-universal.apk 2>&1 | tee "$EV/01-install.log" | grep -q Success || fail install
adb shell pm list packages | grep -q "$PKG" || fail "package missing after install"
adb shell am start -W -n $PKG/.MainActivity | tee "$EV/02-launch.log"
sleep 30
adb exec-out screencap -p > "$EV/02-launch.png"
adb shell pidof $PKG || fail "process not running 30s after launch"
# go to the "Share screen" tab where ID + password are shown
adb shell uiautomator dump /sdcard/ui.xml >/dev/null; adb pull /sdcard/ui.xml "$EV/02-ui.xml"
B=$(python3 - "$EV/02-ui.xml" <<'P'
import re,sys
x=open(sys.argv[1],encoding='utf8').read()
for m in re.finditer(r'<node [^>]*>',x):
    n=m.group(0)
    if re.search(r'(text|content-desc)="[^"]*(Share screen|اشتراک)',n):
        a=list(map(int,re.findall(r'\d+',re.search(r'bounds="([^"]+)"',n).group(1))))
        print((a[0]+a[2])//2,(a[1]+a[3])//2);break
P
)
[ -n "$B" ] && adb shell input tap $B
sleep 8
adb exec-out screencap -p > "$EV/03-id-password.png"
adb shell uiautomator dump /sdcard/ui2.xml >/dev/null; adb pull /sdcard/ui2.xml "$EV/03-ui.xml"
grep -oE '(text|content-desc)="[^"]*"' "$EV/03-ui.xml" | tee "$EV/03-visible-text.log"
grep -qE '"[0-9 ]{9,13}"|[0-9]{3} [0-9]{3} [0-9]{3}' "$EV/03-ui.xml" && echo "ID visible" | tee -a "$EV/result.log" || echo "WARN: ID not found in ui dump (see screenshot)" | tee -a "$EV/result.log"
adb logcat -d > "$EV/logcat-full.log"
if grep -E "FATAL EXCEPTION|AndroidRuntime: Process: $PKG|Fatal signal" "$EV/logcat-full.log" > "$EV/crash.log"; then fail "crash in logcat"; fi
adb shell pidof $PKG || fail "process died"
adb uninstall $PKG | tee "$EV/04-uninstall.log" | grep -q Success || fail uninstall
adb shell pm list packages | grep -q "$PKG" && fail "package still present after uninstall"
adb exec-out screencap -p > "$EV/04-after-uninstall.png"
echo "ANDROID OK" | tee -a "$EV/result.log"
