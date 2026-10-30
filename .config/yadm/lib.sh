#!/bin/sh

_state=$(mktemp -d)
trap 'rm -rf "$_state"' EXIT
: >"$_state/results"
: >"$_state/todo"

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  _tty=1
  _bold=$(printf '\033[1m')
  _dim=$(printf '\033[2m')
  _red=$(printf '\033[31m')
  _green=$(printf '\033[32m')
  _yellow=$(printf '\033[33m')
  _blue=$(printf '\033[34m')
  _reset=$(printf '\033[0m')
  _clear=$(printf '\r\033[K')
else
  _tty= _bold= _dim= _red= _green= _yellow= _blue= _reset= _clear=
fi

have() { command -v "$1" >/dev/null 2>&1; }

is_class() { yadm config --get-all local.class 2>/dev/null | grep -qx "$1"; }

already() { printf '%s\n' "$*" >"$_state/already"; exit 0; }
skip() { printf '%s\n' "$*" >"$_state/skip"; exit 0; }
fail() { printf '%s\n' "$*" >"$_state/fail"; exit 1; }
stop() { printf '%s\n' "$*" >"$_state/stop"; exit 1; }
note() { printf '%s\n' "$*" >"$_state/note"; }
todo() { printf '%s\n' "$*" >>"$_state/todo"; }

ask() {
  sleep 0.1
  printf '    %s│%s %s ' "$_dim" "$_reset" "$*" >/dev/tty
  read -r _answer
}

title() {
  printf '\n  %s%s%s  %s\n' "$_bold" "$1" "$_reset" "$2"
  if [ -n "$3" ]; then printf '  %s%s%s\n' "$_dim" "$3" "$_reset"; fi
  printf '\n'
}

_line() {
  _tail=
  if [ -n "$6" ]; then _tail=" $_dim· $6$_reset"; fi
  printf '  %s%s%s %s%-17s%s %s%s%s%s\n' \
    "$1" "$2" "$_reset" "$3" "$4" "$_reset" "$3" "$5" "$_reset" "$_tail"
}

result() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$4" >>"$_state/results"
  case "$1" in
    done) _line "$_green" '✓' "$_bold" "$2" "$3" "$4" ;;
    already) _line "$_dim$_green" '✓' "$_dim" "$2" "$3" "$4" ;;
    off) _line "$_dim" '○' "$_dim" "$2" "$3" "$4" ;;
    skip) _line "$_yellow" '–' '' "$2" "$3" "$4" ;;
    fail) _line "$_red" '✗' "$_bold" "$2" "$3" "$_red$4$_reset" ;;
  esac
}

status_of() {
  awk -F '\t' -v name="$1" '$2 == name { s = $1 } END { print s }' "$_state/results"
}

_stream() {
  awk -v first="$1" -v mark="$_state/output" -v bar="    $_dim│ " -v reset="$_reset" '
    NR == 1 { printf "%s", first; printf "" > mark }
    { print bar $0 reset; fflush() }'
}

run() {
  _name=$1 _desc=$2
  shift 2
  for _need in "$@"; do
    case "$(status_of "$_need")" in
      skip | fail | off)
        result skip "$_name" "$_desc" "needs $_need"
        return 0 ;;
    esac
  done
  rm -f "$_state/already" "$_state/skip" "$_state/stop" "$_state/fail" \
    "$_state/note" "$_state/output"
  if [ -n "$_tty" ]; then
    printf '  %s◌%s %s%-17s%s %s' "$_blue" "$_reset" "$_bold" "$_name" "$_reset" "$_desc"
    _first='\n'
  else
    _first=$(printf '  ● %-17s %s' "$_name" "$_desc")'\n'
  fi
  { (set -e; "step_$_name"); echo $? >"$_state/rc"; } 2>&1 | _stream "$_first"
  _rc=$(cat "$_state/rc")
  if [ -n "$_tty" ] && [ ! -f "$_state/output" ]; then printf '%s' "$_clear"; fi
  if [ -f "$_state/stop" ]; then
    result fail "$_name" "$_desc" "$(cat "$_state/stop")"
    finish
  elif [ -f "$_state/fail" ]; then
    result fail "$_name" "$_desc" "$(cat "$_state/fail")"
  elif [ "$_rc" -ne 0 ]; then
    result fail "$_name" "$_desc" "exited with $_rc, see the output above"
  elif [ -f "$_state/skip" ]; then
    result skip "$_name" "$_desc" "$(cat "$_state/skip")"
  elif [ -f "$_state/already" ]; then
    result already "$_name" "$_desc" "$(cat "$_state/already")"
  else
    result done "$_name" "$_desc" "$(cat "$_state/note" 2>/dev/null)"
  fi
}

desktop_only() {
  if is_class headless; then
    result off "$1" "$2" 'desktop only'
  else
    run "$@"
  fi
}

work_only() {
  if is_class work; then
    run "$@"
  else
    result off "$1" "$2" 'work machines only'
  fi
}

finish() {
  printf '\n'
  awk -F '\t' -v bold="$_bold" -v dim="$_dim" -v red="$_red" \
    -v green="$_green" -v yellow="$_yellow" -v reset="$_reset" '
    { count[$1]++ }
    $1 == "fail" { failed = failed sprintf("    %s✗%s %-17s %s%s%s\n", red, reset, $2, red, $3, reset) }
    $1 == "skip" { skipped = skipped sprintf("    %s–%s %-17s %s%s%s\n", yellow, reset, $2, dim, $3, reset) }
    END {
      printf "  %s%d done%s  %s%d already done%s  %s%d skipped%s  %s%d failed%s\n",
        green, count["done"], reset, dim, count["already"], reset,
        yellow, count["skip"] + count["off"], reset,
        (count["fail"] ? red : dim), count["fail"], reset
      if (failed) printf "\n  %sFailed%s\n%s", bold, reset, failed
      if (skipped) printf "\n  %sSkipped%s\n%s", bold, reset, skipped
    }' "$_state/results"
  if [ -s "$_state/todo" ]; then
    printf '\n  %sTo do%s\n' "$_bold" "$_reset"
    sed "s/^/    $_blue•$_reset /" "$_state/todo"
  fi
  if grep -q '^fail' "$_state/results"; then
    printf '\n  Fix what failed, then run %syadm bootstrap%s again.\n\n' "$_bold" "$_reset"
    exit 1
  fi
  printf '\n'
  exit 0
}
