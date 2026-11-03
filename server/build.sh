#!/usr/bin/env bash
# Build hbbs/hbbr (Linux x86_64) from rustdesk-server source (AGPL-3.0). Output: server/bin/
set -euo pipefail
REF="${1:-1.1.16}"
D="$(cd "$(dirname "$0")" && pwd)"; W="$(mktemp -d)"
git clone --depth 1 --branch "$REF" --recurse-submodules https://github.com/rustdesk/rustdesk-server "$W/src"
(cd "$W/src" && cargo build --release --bin hbbs --bin hbbr)
mkdir -p "$D/bin" && cp "$W/src/target/release/hbbs" "$W/src/target/release/hbbr" "$D/bin/"
echo "built: $D/bin/hbbs $D/bin/hbbr"
