#!/usr/bin/env bash
# NexlyDesk server (hbbs + hbbr) one-command installer for a Linux VPS (systemd).
# NOT deployed automatically. Usage (as root):
#   sudo bash install.sh [--port443] [--bin-dir DIR] [--relay HOST]
#   --port443   run the ID server on TCP/UDP 443 (useful on filtered networks) instead of 21116
#   --bin-dir   directory that already contains hbbs and hbbr (default: next to this script, ./bin)
#   --relay     public host/IP clients should use for the relay (default: auto-detected public IP)
set -euo pipefail
PORT=21116; RELAY_PORT=21117
BIN_DIR="$(cd "$(dirname "$0")" && pwd)/bin"; RELAY=""
while [ $# -gt 0 ]; do case "$1" in
  --port443) PORT=443;; --bin-dir) BIN_DIR="$2"; shift;; --relay) RELAY="$2"; shift;;
  *) echo "unknown option $1"; exit 2;; esac; shift; done
[ "$(id -u)" = 0 ] || { echo "run as root"; exit 1; }
for b in hbbs hbbr; do [ -x "$BIN_DIR/$b" ] || { echo "missing $BIN_DIR/$b (build with server/build.sh or download the CI artifact)"; exit 1; }; done
[ -n "$RELAY" ] || RELAY="$(hostname -I | awk '{print $1}')"
id nexlydesk >/dev/null 2>&1 || useradd --system --home /var/lib/nexlydesk --shell /usr/sbin/nologin nexlydesk
install -d -o nexlydesk -g nexlydesk /var/lib/nexlydesk
install -m 755 "$BIN_DIR/hbbs" "$BIN_DIR/hbbr" /usr/local/bin/
CAP=""; [ "$PORT" -lt 1024 ] && CAP="AmbientCapabilities=CAP_NET_BIND_SERVICE"
cat > /etc/systemd/system/nexlydesk-hbbr.service <<U
[Unit]
Description=NexlyDesk relay server (hbbr)
After=network-online.target
[Service]
User=nexlydesk
WorkingDirectory=/var/lib/nexlydesk
ExecStart=/usr/local/bin/hbbr -p $RELAY_PORT
Restart=always
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
U
cat > /etc/systemd/system/nexlydesk-hbbs.service <<U
[Unit]
Description=NexlyDesk ID/rendezvous server (hbbs)
After=network-online.target nexlydesk-hbbr.service
[Service]
User=nexlydesk
WorkingDirectory=/var/lib/nexlydesk
ExecStart=/usr/local/bin/hbbs -p $PORT -r $RELAY:$RELAY_PORT
$CAP
Restart=always
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
U
systemctl daemon-reload
systemctl enable --now nexlydesk-hbbr nexlydesk-hbbs
if command -v ufw >/dev/null && ufw status | grep -q active; then
  ufw allow $PORT/tcp; ufw allow $PORT/udp; ufw allow $((PORT-1))/tcp; ufw allow $((PORT+2))/tcp
  ufw allow $RELAY_PORT/tcp; ufw allow $((RELAY_PORT+2))/tcp
fi
for i in $(seq 1 20); do [ -f /var/lib/nexlydesk/id_ed25519.pub ] && break; sleep 1; done
echo "== NexlyDesk server installed =="
echo "ID server : $RELAY:$PORT   (put this in NexlyDesk > Settings > Network > ID server)"
echo "Relay     : $RELAY:$RELAY_PORT"
echo "Public key: $(cat /var/lib/nexlydesk/id_ed25519.pub 2>/dev/null || echo '(not generated yet: check journalctl -u nexlydesk-hbbs)')"
echo "To bake into the app: set BRAND_DEFAULT_SERVER and RS_PUB_KEY in libs/hbb_common/src/config.rs"
