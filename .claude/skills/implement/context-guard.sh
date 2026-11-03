#!/usr/bin/env bash
# PostToolUse hook: tells Claude once when the thread's context passes the handoff limit.
# Context size = input + cache + output tokens of the latest main-thread assistant turn.
limit=${IMPLEMENT_CONTEXT_LIMIT:-350000}

input=$(cat)
session=$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)
transcript=$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null)
marker="${TMPDIR:-/tmp}/implement-context-guard-$session"

[[ -n $session && -f $transcript && ! -e $marker ]] || exit 0

tokens=$(tail -c 1000000 "$transcript" | tail -n +2 | jq -Rn '
  [inputs | fromjson? | select(.type == "assistant" and (.isSidechain | not) and .message.usage)]
  | last | .message.usage // empty
  | (.input_tokens // 0) + (.cache_creation_input_tokens // 0)
    + (.cache_read_input_tokens // 0) + (.output_tokens // 0)' 2>/dev/null)

[[ $tokens =~ ^[0-9]+$ ]] && ((tokens >= limit)) || exit 0

echo "$tokens" >"$marker"
jq -n --arg k "$((tokens / 1000))" --arg l "$((limit / 1000))" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: "Context limit reached: this thread is at about \($k)k tokens, past the \($l)k handoff point set by the implement skill."
  }
}'
exit 0
