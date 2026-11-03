#!/usr/bin/env bash
# Expose local TCP 21118 publicly with bore (free, no account). Writes "host:port" to $1.
set -x
curl -sL https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz | tar xz -C /tmp
nohup /tmp/bore local 21118 --to bore.pub > /tmp/bore.log 2>&1 &
for i in $(seq 1 30); do EP=$(grep -oE 'bore\.pub:[0-9]+' /tmp/bore.log | head -1); [ -n "$EP" ] && break; sleep 2; done
cat /tmp/bore.log; [ -n "$EP" ] || { echo "tunnel failed"; exit 1; }
echo "$EP" > "$1"; echo "endpoint $EP"
H=${EP%:*}; P=${EP#*:}; timeout 10 bash -c "</dev/tcp/$H/$P" && echo "public endpoint reachable (self-test)" || echo "WARN: public endpoint NOT reachable (self-test)"
