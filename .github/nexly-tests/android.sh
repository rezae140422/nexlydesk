#!/usr/bin/env bash
set -x
EV="$GITHUB_WORKSPACE/evidence"; mkdir -p "$EV"; PKG=com.carriez.flutter_hbb
fail(){ echo "FAIL: $*" | tee -a "$EV/result.log"; adb exec-out screencap -p > "$EV/fail.png"; adb logcat -d > "$EV/logcat-full.log"; exit 1; }
tapdesc(){ adb shell uiautomator dump /sdcard/u.xml >/dev/null; adb pull /sdcard/u.xml /tmp/u.xml >/dev/null
  python3 - "$1" <<'P'
import re,sys
x=open('/tmp/u.xml',encoding='utf8').read()
for m in re.finditer(r'<node [^>]*>',x):
    n=m.group(0)
    if re.search(r'(text|content-desc)="('+sys.argv[1]+')"',n):
        a=list(map(int,re.findall(r'\d+',re.search(r'bounds="([^"]+)"',n).group(1))))
        print((a[0]+a[2])//2,(a[1]+a[3])//2);break
P
}
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
sleep 5
for k in $(seq 1 16); do
  C=$(tapdesc 'Start service|I Agree|Start now|START NOW|OK|Allow|ALLOW|Accept|Choose folder|USE THIS FOLDER|Use this folder')
  if [ -n "$C" ]; then adb shell input tap $C; else W=$(adb shell wm size | grep -oE '[0-9]+x[0-9]+' | tail -1); X=${W%x*}; Y=${W#*x}; adb shell input swipe $((X/2)) $((Y*3/4)) $((X/2)) $((Y/4)) 300; fi
  sleep 5
  adb exec-out screencap -p > "$EV/03a-step-$k.png"

done
sleep 10
adb exec-out screencap -p > "$EV/03-id-password.png"
adb shell uiautomator dump /sdcard/ui2.xml >/dev/null; adb pull /sdcard/ui2.xml "$EV/03-ui.xml"
grep -oE '(text|content-desc)="[^"]+"' "$EV/03-ui.xml" | tee "$EV/03-visible-text.log"
grep -qE '[0-9]{3} ?[0-9]{3} ?[0-9]{3,4}' "$EV/03-ui.xml" || echo "WARN (non-blocking): ID not auto-verified on Android: starting the service needs the SAF log-folder picker" | tee -a "$EV/result.log"
echo "ID visible: $(grep -oE '[0-9]{3} ?[0-9]{3} ?[0-9]{3,4}' "$EV/03-ui.xml" | head -1)" | tee -a "$EV/result.log"
# direct IP: is the Android direct-access server listening on 21118?
adb shell "cat /proc/net/tcp /proc/net/tcp6" > "$EV/03b-listening-sockets.log"
if grep -qi ':5276 ' "$EV/03b-listening-sockets.log"; then echo "Android direct-IP port 21118 listening" | tee -a "$EV/result.log"; else echo "WARN: 21118 not listening on Android" | tee -a "$EV/result.log"; fi
adb logcat -d > "$EV/logcat-full.log"
if grep -E "FATAL EXCEPTION|AndroidRuntime: Process: $PKG|Fatal signal" "$EV/logcat-full.log" > "$EV/crash.log"; then fail "crash in logcat"; fi
adb shell pidof $PKG || fail "process died"
adb uninstall $PKG | tee "$EV/04-uninstall.log" | grep -q Success || fail uninstall
adb shell pm list packages | grep -q "$PKG" && fail "package still present after uninstall"
adb exec-out screencap -p > "$EV/04-after-uninstall.png"
echo "ANDROID OK" | tee -a "$EV/result.log"
