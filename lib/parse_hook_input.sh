#!/bin/bash
# parse_hook_input: single jq call → flat shell vars via eval
parse_hook_input() {
  local input="$1"
  eval "$(echo "$input" | jq -r '
    "MODEL="          + (.model.display_name // "Claude" | @sh),
    "MODEL_ID="       + (.model.id // "" | @sh),
    "CC_VERSION="     + (.version // "" | @sh),
    "TRANSCRIPT="     + (.transcript_path // "" | @sh),
    "CWD_REAL="       + (.workspace.current_dir // .cwd // "" | @sh),
    "CTX_PCT="        + ((.context_window.used_percentage // 0) | floor | tostring),
    "WINDOW="         + ((.context_window.context_window_size // 200000) | if type == "number" then floor else 200000 end | tostring),
    "CTX_TOKENS="     + (((.context_window.current_usage.input_tokens // 0)
                        + (.context_window.current_usage.cache_creation_input_tokens // 0)
                        + (.context_window.current_usage.cache_read_input_tokens // 0)) | tostring),
    "IN_TOKENS="      + (.context_window.total_input_tokens // 0 | tostring),
    "OUT_TOKENS="     + (.context_window.total_output_tokens // 0 | tostring),
    "CACHED_TOKENS="  + (.context_window.current_usage.cache_read_input_tokens // 0 | tostring),
    "COST_USD="       + (.cost.total_cost_usd // 0 | tostring),
    "DURATION_MS="    + (.cost.total_duration_ms // 0 | tostring),
    "RL_5H_PCT="      + ((.rate_limits.five_hour.used_percentage // .rate_limits.five_hour.utilization // -1) | floor | tostring),
    "RL_5H_RESET="    + ((.rate_limits.five_hour.resets_at // 0) | floor | tostring),
    "RL_7D_PCT="      + ((.rate_limits.seven_day.used_percentage // .rate_limits.seven_day.utilization // -1) | floor | tostring),
    "RL_7D_RESET="    + ((.rate_limits.seven_day.resets_at // 0) | floor | tostring)
  ')"
  CWD=$(basename "$CWD_REAL")
  TOTAL_IO=$((IN_TOKENS + OUT_TOKENS))
}
