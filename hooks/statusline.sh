#!/bin/bash
# statusline.sh — Claude Code statusline
#
# Renders: 5-hour rate-limit usage progress bar + time remaining until reset

set -uo pipefail

INPUT="$(cat)"

# --- Model name ---------------------------------------------------------
MODEL_NAME="$(printf '%s' "$INPUT" | jq -r '.model.display_name // empty' 2>/dev/null || true)"
DIM_CYAN=$'\033[2;36m'
RESET_C=$'\033[0m'
if [ -n "$MODEL_NAME" ]; then
  printf "${DIM_CYAN}%s${RESET_C}  " "$MODEL_NAME"
fi

# --- Live context window usage ------------------------------------------
CTX_USED_PCT="$(printf '%s' "$INPUT" | jq -r '.context_window.used_percentage // empty' 2>/dev/null || true)"
CTX_TOTAL_INPUT="$(printf '%s' "$INPUT" | jq -r '.context_window.total_input_tokens // empty' 2>/dev/null || true)"
CTX_WINDOW_SIZE="$(printf '%s' "$INPUT" | jq -r '.context_window.context_window_size // empty' 2>/dev/null || true)"

if [ -n "$CTX_USED_PCT" ] && [ -n "$CTX_TOTAL_INPUT" ] && [ -n "$CTX_WINDOW_SIZE" ]; then
  CTX_PCT_INT="$(printf '%.0f' "$CTX_USED_PCT" 2>/dev/null || echo 0)"
  if [ "$CTX_PCT_INT" -lt 0 ]; then CTX_PCT_INT=0; fi
  if [ "$CTX_PCT_INT" -gt 100 ]; then CTX_PCT_INT=100; fi

  # Human-readable token counts, e.g. 42.3k / 200k.
  fmt_tokens() {
    local tokens="$1"
    if [ "$tokens" -ge 1000 ]; then
      awk -v t="$tokens" 'BEGIN { printf "%.1fk", t / 1000 }'
    else
      printf '%d' "$tokens"
    fi
  }
  USED_FMT="$(fmt_tokens "$CTX_TOTAL_INPUT")"
  MAX_FMT="$(fmt_tokens "$CTX_WINDOW_SIZE")"

  CTX_COLOR='\033[1;31m'   # bold red
  CTX_RESET='\033[0m'

  printf "${CTX_COLOR}ctx %s/%s (%d%%)${CTX_RESET}  " "$USED_FMT" "$MAX_FMT" "$CTX_PCT_INT"
fi

# --- 5-hour rate-limit usage bar + reset countdown --------------------------
USED_PCT="$(printf '%s' "$INPUT" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null || true)"
RESETS_AT="$(printf '%s' "$INPUT" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null || true)"

if [ -n "$USED_PCT" ]; then
  # Round to nearest integer, clamp to [0, 100].
  PCT_INT="$(printf '%.0f' "$USED_PCT" 2>/dev/null || echo 0)"
  if [ "$PCT_INT" -lt 0 ]; then PCT_INT=0; fi
  if [ "$PCT_INT" -gt 100 ]; then PCT_INT=100; fi

  # Build a 10-segment block bar.
  TOTAL_SEGMENTS=10
  FILLED=$(( PCT_INT * TOTAL_SEGMENTS / 100 ))
  EMPTY=$(( TOTAL_SEGMENTS - FILLED ))

  BAR=""
  i=0
  while [ "$i" -lt "$FILLED" ]; do BAR="${BAR}█"; i=$((i + 1)); done
  i=0
  while [ "$i" -lt "$EMPTY" ]; do BAR="${BAR}░"; i=$((i + 1)); done

  # Color by severity: dim green < 60%, dim yellow < 85%, dim red >= 85%.
  if [ "$PCT_INT" -ge 85 ]; then
    COLOR='\033[2;31m'   # dim red
  elif [ "$PCT_INT" -ge 60 ]; then
    COLOR='\033[2;33m'   # dim yellow
  else
    COLOR='\033[2;32m'   # dim green
  fi
  RESET='\033[0m'

  # Time remaining until reset, derived from the resets_at unix epoch.
  REMAINING_STR=""
  if [ -n "$RESETS_AT" ]; then
    NOW_EPOCH="$(date +%s)"
    RESETS_AT_INT="$(printf '%.0f' "$RESETS_AT" 2>/dev/null || echo "$NOW_EPOCH")"
    DIFF=$(( RESETS_AT_INT - NOW_EPOCH ))
    if [ "$DIFF" -lt 0 ]; then DIFF=0; fi
    HOURS=$(( DIFF / 3600 ))
    MINUTES=$(( (DIFF % 3600) / 60 ))
    if [ "$HOURS" -gt 0 ]; then
      REMAINING_STR="${HOURS}h${MINUTES}m"
    else
      REMAINING_STR="${MINUTES}m"
    fi
  fi

  # Absolute reset time in Bangkok (Asia/Bangkok, UTC+7).
  RESET_LOCAL=""
  if [ -n "$RESETS_AT" ]; then
    RESET_LOCAL="$(TZ='Asia/Bangkok' date -r "$RESETS_AT_INT" '+%H:%M' 2>/dev/null || true)"
  fi

  printf "${COLOR}5h [%s] %d%%${RESET}" "$BAR" "$PCT_INT"
  if [ -n "$REMAINING_STR" ]; then
    printf "${COLOR} (resets in %s" "$REMAINING_STR"
    if [ -n "$RESET_LOCAL" ]; then
      printf ", %s BKK" "$RESET_LOCAL"
    fi
    printf ")${RESET}"
  fi
fi

printf '\n'
