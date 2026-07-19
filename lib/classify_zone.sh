#!/bin/bash
# classify_zone MODEL_ID MODEL CTX_TOKENS WINDOW
# WINDOW is the model's real context window size (from Claude Code's
# context_window.context_window_size hook field). Falls back to
# 200000 if omitted or invalid.
# prints tab-separated: WINDOW T_DRIFT T_DUMB ZONE_COLOR ZONE_LABEL
classify_zone() {
  local model_id="$1" model="$2" ctx_tokens="$3" window="$4"

  local GREEN='\033[38;5;158m' YELLOW='\033[38;5;215m' RED='\033[38;5;203m'

  [[ "$window" =~ ^[0-9]+$ ]] && [ "$window" -gt 0 ] || window=200000

  local t_drift t_dumb
  if [ "$window" -eq 1000000 ]; then
    # extended 1M-context model (e.g. Sonnet 5, Sonnet 4.6 with a 1M window)
    t_drift=200000; t_dumb=400000
  elif [[ "$model_id" == *opus* ]] || [[ "$model" == *Opus* ]]; then
    t_drift=120000; t_dumb=160000
  elif [[ "$model_id" == *haiku* ]] || [[ "$model" == *Haiku* ]]; then
    t_drift=60000;  t_dumb=100000
  else
    t_drift=80000;  t_dumb=120000
  fi

  local zone_color zone_label
  if   [ "$ctx_tokens" -ge "$t_dumb" ];  then zone_color="$RED";    zone_label="🤪 dumb zone"
  elif [ "$ctx_tokens" -ge "$t_drift" ]; then zone_color="$YELLOW"; zone_label="🥱 drifting"
  else                                        zone_color="$GREEN";  zone_label="🧐 smart zone"
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$window" "$t_drift" "$t_dumb" "$zone_color" "$zone_label"
}
