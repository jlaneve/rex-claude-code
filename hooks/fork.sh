#!/usr/bin/env bash
set -euo pipefail

direction=right
dry_run=0
for arg in "$@"; do
  case "$arg" in
    right|left|above|below) direction=$arg ;;
    --dry-run) dry_run=1 ;;
    *) echo "usage: /fork-rex [right|left|above|below] [--dry-run]" >&2; exit 2 ;;
  esac
done

if [ -z "${CLAUDE_CODE_SESSION_ID:-}" ]; then
  echo "CLAUDE_CODE_SESSION_ID is not set; run this from inside Claude Code." >&2
  exit 1
fi

cmd=(rex run --cwd "$PWD")
if [ -n "${REX_BLOCK:-}" ]; then
  cmd+=(--split "$direction" -b "$REX_BLOCK")
fi
cmd+=(-- claude --resume "$CLAUDE_CODE_SESSION_ID" --fork-session)

if [ "$dry_run" = 1 ]; then
  printf '%q ' "${cmd[@]}"
  echo
  exit 0
fi

"${cmd[@]}"
if [ -n "${REX_BLOCK:-}" ]; then
  echo "Forked session $CLAUDE_CODE_SESSION_ID into a new pane ($direction)."
else
  echo "Not inside Rex; forked session $CLAUDE_CODE_SESSION_ID into a new Rex window."
fi
