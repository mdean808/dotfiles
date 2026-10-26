#!/usr/bin/env bash
MAX_QUESTIONS=1
MAX_CHARS=250   # question + all option labels/descriptions combined

input=$(cat)
read -r nq total <<< "$(echo "$input" | jq -r '
  .tool_input.questions as $q
  | [ ($q | length),
      ([ $q[] | (.question | length)
          + ([ .options[]? | (.label | length) + ((.description // "") | length) ] | add // 0)
       ] | add // 0)
    ] | @tsv')"

if [ "${nq:-99}" -le "$MAX_QUESTIONS" ] && [ "${total:-9999}" -le "$MAX_CHARS" ]; then
  exit 0
fi

jq -n '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: "Too long for the picker. Ask as plain text: numbered, brief context each, mark your suggestion and say why. Keep it short."
}}'
exit 0
