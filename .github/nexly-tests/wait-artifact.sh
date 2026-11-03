#!/usr/bin/env bash
# wait-artifact.sh NAME DEST TIMEOUT_S : wait until another job of this run uploads artifact NAME, extract to DEST
N=$1; D=$2; T=${3:-1800}; mkdir -p "$D"
for i in $(seq 0 15 "$T"); do
  ID=$(gh api "repos/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID/artifacts" --jq ".artifacts[]|select(.name==\"$N\")|.id" 2>/dev/null | head -1)
  if [ -n "$ID" ]; then gh api "repos/$GITHUB_REPOSITORY/actions/artifacts/$ID/zip" > /tmp/$N.zip && (cd "$D" && unzip -o /tmp/$N.zip) && exit 0; fi
  sleep 15
done
echo "timeout waiting for artifact $N"; exit 1
