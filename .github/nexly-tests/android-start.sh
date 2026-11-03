#!/usr/bin/env bash
# Install + launch NexlyDesk, start sharing (no SAF picker; MediaProjection auto-accepted), verify full ID and 21118.
set -x
EV="$GITHUB_WORKSPACE/evidence"; mkdir -p "$EV"; PKG=com.carriez.flutter_hbb
fail(){ echo "FAIL: $*" | tee -a "$EV/result.log"; adb exec-out screencap -p > "$EV/fail.png"; adb logcat -d > "$EV/logcat-full.log"; exit 1; }
dump(){ adb shell uiautomator dump /sdcard/u.xml >/dev/null 2>&1; adb pull /sdcard/u.xml "${1:-/tmp/u.xml}" >/dev/null 2>&1; }
tapdesc(){ dump; python3 - "$1" <<'P'
import re,sys
x=open('/tmp/u.xml',encoding='utf8').read()
for m in re.finditer(r'<node [^>]*>',x):
    n=m.group(0)
    if re.search(r'(text|content-desc)="('+sys.argv[1]+')"',n):
        a=list(map(int,re.findall(r'\d+',re.search(r'bounds="([^"]+)"',n).group(1))))
        print((a[0]+a[2])//2,(a[1]+a[3])//2);break
P
}
listening(){ adb shell "cat /proc/net/tcp /proc/net/tcp6" > "$EV/03b-listening-sockets.log"; grep -qiE ':527E [0-9A-F:]+ 0A' "$EV/03b-listening-sockets.log"; }
adb logcat -c
adb install -r -g dist/NexlyDesk-android-universal.apk 2>&1 | tee "$EV/01-install.log" | grep -q Success || fail install
# pre-grant what can be pre-granted; MediaProjection is still confirmed by tapping the system dialog below
adb shell appops set $PKG SYSTEM_ALERT_WINDOW allow; adb shell appops set $PKG PROJECT_MEDIA allow
adb shell am start -W -n $PKG/.MainActivity | tee "$EV/02-launch.log"
sleep 30
adb exec-out screencap -p > "$EV/02-launch.png"
adb shell pidof $PKG || fail "process not running 30s after launch"
B=$(tapdesc '[^"]*(Share screen|اشتراک)[^"]*'); [ -n "$B" ] && adb shell input tap $B
sleep 5
SAF=0
shot(){ adb exec-out screencap -p > "$EV/03a-$1.png"; dump; cp /tmp/u.xml "$EV/03a-$1.xml"; grep -qE 'com.android.documentsui|USE THIS FOLDER|Use this folder' /tmp/u.xml && SAF=1; }
started(){ listening && grep -qE 'text="[0-9]{1,3}( ?[0-9]{3}){2,3}"' /tmp/u.xml && ! grep -q 'Service is not running' /tmp/u.xml; }
for round in 1 2 3; do
  shot "r$round-0"; started && break
  C=$(tapdesc 'Start service'); [ -n "$C" ] && adb shell input tap $C
  sleep 3; shot "r$round-1"
  if grep -q 'I Agree' /tmp/u.xml; then
    sleep 15   # scam-warning countdown
    C=$(tapdesc 'I Agree'); adb shell input tap $C; sleep 3; shot "r$round-2"
  fi
  for k in $(seq 1 10); do
    started && break
    C=$(tapdesc 'Start now|START NOW|OK|Allow|ALLOW|Accept|Continue|I Agree')
    if [ -n "$C" ]; then adb shell input tap $C
    elif ! grep -q "package=\"$PKG\"" /tmp/u.xml; then adb shell input keyevent KEYCODE_BACK; fi
    sleep 4; shot "r$round-s$k"
  done
  started && break
done
sleep 5
adb exec-out screencap -p > "$EV/03-id-password.png"
dump "$EV/03-ui.xml"
python3 - "$EV/03-ui.xml" > "$EV/03-parsed.env" <<'P'
import re,sys,html
x=open(sys.argv[1],encoding='utf8').read()
parts=[]
for v in re.findall(r'(?:text|content-desc)="([^"]*)"',x):
    parts+= [p.strip() for p in html.unescape(v).split('\n') if p.strip()]
idv=next((p for p in parts if re.fullmatch(r'\d{1,3}( ?\d{3}){2,3}',p)),'')
otp=''
if idv:
    i=parts.index(idv)
    otp=next((q for q in parts[i+1:i+4] if re.fullmatch(r'[A-Za-z0-9]{6,10}',q) and not q.isdigit()),'')
print(f"ANDROID_ID='{idv}'\nANDROID_OTP='{otp}'")
P
cat "$EV/03-parsed.env"; . "$EV/03-parsed.env"
echo "SAF folder picker shown during start: $SAF" | tee -a "$EV/result.log"
[ "$SAF" = 0 ] || fail "SAF folder picker still appears when starting sharing"
[ -n "$ANDROID_ID" ] || fail "ID not shown in full on the share screen"
echo "ID visible in full: $ANDROID_ID" | tee -a "$EV/result.log"
listening || fail "21118 not listening on Android after starting sharing"
echo "Android direct-IP port 21118 listening" | tee -a "$EV/result.log"
if grep -qE 'در حال برقراری|در حال اتصال به شبکه|Connecting to the' "$EV/03-ui.xml"; then fail "stuck rendezvous status message is shown"; fi
echo "stuck 'connecting' message absent" | tee -a "$EV/result.log"
grep -q 'آماده‌ی اتصال مستقیم' "$EV/03-ui.xml" && echo "green direct-ready status shown" | tee -a "$EV/result.log" || fail "direct-ready status not shown"
grep -qE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$EV/03-ui.xml" && echo "local IPv4 shown: $(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "$EV/03-ui.xml" | grep -v 192.168.1.20 | sort -u | tr '\n' ' ')" | tee -a "$EV/result.log"
adb shell pidof $PKG || fail "process died"
