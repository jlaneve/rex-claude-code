#!/usr/bin/env bash
set -euo pipefail

transcript=$1
done_marker=$2
title=${3:-subagent}
linger=${REX_SUBAGENT_LINGER:-5}
trap 'kill $(jobs -p) 2>/dev/null' EXIT

printf '\033]0;%s\007' "$title"
printf '\033[1m%s\033[0m\n\n' "$title"

until [ -f "$transcript" ] || [ -f "$done_marker" ]; do sleep 0.2; done

tail -n +1 -F "$transcript" 2>/dev/null | jq --unbuffered -r '
  def dim: "\u001b[2m" + . + "\u001b[0m";
  def cyan: "\u001b[36m" + . + "\u001b[0m";
  def red: "\u001b[31m" + . + "\u001b[0m";
  def clip($n): gsub("\\s+"; " ") | if length > $n then .[:$n] + "…" else . end;
  def text_of: if type == "string" then . else (map(select(.type == "text") | .text) | join(" ")) end;
  def summary:
    .command // .file_path // .pattern // .url // .query // .description // .prompt // (tostring)
    | tostring | clip(120);

  if .type == "user" and (.message.content | type) == "string" then
    select(.message.content | startswith("<system-reminder>") | not) |
    ("> " + (.message.content | clip(400))) | dim
  elif .type == "user" then
    .message.content[]
    | select(.type == "tool_result")
    | (.content | text_of | clip(100)) as $out
    | if .is_error then ("  ✗ " + $out | red) else ("  " + $out | dim) end
  elif .type == "assistant" then
    .message.content[]
    | if .type == "text" then "\n" + .text + "\n"
      elif .type == "tool_use" then ("→ " + .name | cyan) + " " + (.input | summary | dim)
      else empty end
  else empty end
' &

until [ -f "$done_marker" ]; do sleep 0.5; done
rm -f "$done_marker"
sleep 1
printf '\n\033[2m(finished; closing in %ss)\033[0m\n' "$linger"
sleep "$linger"
