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

call() { rex api call "$1" "$(jq -nc --arg s "$REX_SESSION" "$2 + {session_id: \$s}" "${@:3}")"; }

window=$(call session.view '{}' | jq -r --arg b "$REX_BLOCK" \
  '.windows[] | select([.layers[].blocks[].block_id] | index($b)) | .window_id')

y=$(awk -v s="$slot" 'BEGIN { printf "%.2f", 0.02 + (s % 3) * 0.32 }')
bounds="[0.58, $y, 0.40, 0.30]"
minimize=${REX_SUBAGENT_MINIMIZE:-1}
[ "$minimize" = 1 ] && start_bounds='[0.99, 0.99, 0.01, 0.01]' || start_bounds=$bounds

layer=$(call session.new_layer \
  '{window_id: $w, bounds: $start, focus: false,
    layout: {block: {flavor: "com.superlogical.terminal.shell", label: $t,
      options: {shell: "none", command: ["bash", $watch, $transcript, $marker, $t]}}}}' \
  --arg w "$window" --argjson start "$start_bounds" --arg t "$title" \
  --arg watch "$here/watch.sh" --arg transcript "$transcript" --arg marker "$done_marker" \
  | jq -r '.layer_id')

if [ "$minimize" = 1 ]; then
  call session.set_layer_state '{layer_id: $l, state: "minimized"}' --arg l "$layer" >/dev/null
  call session.resize_layer '{layer_id: $l, bounds: $b}' --arg l "$layer" --argjson b "$bounds" >/dev/null
fi
