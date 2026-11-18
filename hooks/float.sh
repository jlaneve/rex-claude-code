#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "usage: float.sh SLOT TRANSCRIPT DONE_MARKER TITLE" >&2
  exit 2
fi
if [ -z "${REX_SESSION:-}" ] || [ -z "${REX_BLOCK:-}" ]; then
  echo "not inside a Rex pane" >&2
  exit 1
fi

slot=$1 transcript=$2 done_marker=$3 title=$4
here=$(cd "$(dirname "$0")" && pwd)

block=$(rex run --split right -b "$REX_BLOCK" --focus=false --json --label "$title" \
  --shell=none -- bash "$here/watch.sh" "$transcript" "$done_marker" "$title" | jq -r '.block_ids[0]')

focused=$(rex api call session.view "$(jq -nc --arg s "$REX_SESSION" '{session_id: $s}')" \
  | jq -r --arg b "$REX_BLOCK" '.windows[] | select([.layers[].blocks[].block_id] | index($b)) | .focused_block_id')

y=$(awk -v s="$slot" 'BEGIN { printf "%.2f", 0.02 + (s % 3) * 0.32 }')
rex api call session.float_block \
  "$(jq -nc --arg s "$REX_SESSION" --arg b "$block" --argjson y "$y" \
    '{session_id: $s, block_id: $b, bounds: [0.58, $y, 0.40, 0.30]}')" >/dev/null

if [ "${REX_SUBAGENT_MINIMIZE:-1}" = 1 ]; then
  sleep 0.4
  rex focus "$block" >/dev/null
  sleep 0.2
  rex do pane.minimize_floating >/dev/null 2>&1 || true
  rex focus "${focused:-$REX_BLOCK}" >/dev/null
fi
