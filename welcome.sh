#!/usr/bin/env zsh

# ── YOUR CONFIG ──────────────────
YOUR_NAME="__YOUR_NAME__"            # your name for figlet heading
YOUR_CITY="__YOUR_CITY__"            # for weather e.g. "Tallinn"
TEMP_UNIT="__TEMP_UNIT__"            # metric or imperial
PORTRAIT_COLOR="__PORTRAIT_COLOR__"  # ANSI code e.g. 38;5;218 (pink) or 97 (white)
ACCENT_COLOR="__ACCENT_COLOR__"      # ANSI code e.g. 96 (cyan) or 38;5;218 (pink)
WISHES=(
  "Make something beautiful today."
  "You are doing better than you think."
  "Today is a great day to create."
  "Ship it."
  "Your code is poetry."
  "Keep going — momentum is everything."
  "Build things that matter."
  "Every line of code is a choice."
  "You've got this."
  "Create. Iterate. Ship."
)
# ─────────────────────────────────

_welcome_main() {
    local WHITE=$'\033[97m'
    local RESET=$'\033[0m'
    local PORTRAIT_C=""
    local ACCENT_C=""
    [[ -n "$PORTRAIT_COLOR" ]] && PORTRAIT_C=$'\033['"${PORTRAIT_COLOR}m"
    [[ -n "$ACCENT_COLOR"   ]] && ACCENT_C=$'\033['"${ACCENT_COLOR}m"

    local COLS; COLS=$(tput cols 2>/dev/null || echo 120)
    (( COLS < 80 )) && return 0

    local PORTRAIT_W=60
    local GAP=4

    # --- data ---
    local date_str time_str uptime_str weather wish
    date_str=$(date '+%A, %B %d %Y')
    time_str=$(date '+%H:%M')
    uptime_str=$(uptime | sed 's/.*up //' | sed 's/,.*//')

    local unit_flag
    [[ "$TEMP_UNIT" == "imperial" ]] && unit_flag="u" || unit_flag="m"
    local cache="/tmp/tw_${YOUR_CITY// /_}_$(date +%Y%m%d%H).txt"
    if [[ -f "$cache" ]]; then
        weather=$(< "$cache")
    else
        weather=$(curl -s --connect-timeout 2 --max-time 4 \
            "wttr.in/${YOUR_CITY// /+}?format=%C,+%t&${unit_flag}" 2>/dev/null)
        [[ -n "$weather" ]] && printf '%s' "$weather" > "$cache" || weather="—"
    fi

    local wish_count=${#WISHES[@]}
    wish=${WISHES[$((RANDOM % wish_count + 1))]}

    # --- info block ---
    local -a info
    if command -v figlet &>/dev/null; then
        local figline
        local -a figlines=()
        while IFS= read -r figline; do
            figlines+=("$figline")
        done <<< "$(figlet -f slant "$YOUR_NAME" 2>/dev/null)"
        while [[ ${#figlines[@]} -gt 0 && -z "${figlines[-1]// /}" ]]; do
            figlines=(${figlines[1,-2]})
        done
        for figline in "${figlines[@]}"; do
            info+=("${ACCENT_C}${figline}${RESET}")
        done
    else
        info+=("${ACCENT_C}${YOUR_NAME}${RESET}")
    fi
    info+=("")
    info+=("${WHITE}${date_str}${RESET}")
    info+=("${WHITE}${time_str}${RESET}")
    info+=("${WHITE}${weather}${RESET}")
    info+=("${WHITE}uptime  ${uptime_str}${RESET}")
    info+=("${WHITE}zsh${RESET}")
    info+=("")
    info+=("${WHITE}${wish}${RESET}")

    # --- portrait ---
    local -a art
    local art_file="${HOME}/.config/terminal-welcome/ascii.txt"
    if [[ -f "$art_file" ]]; then
        while IFS= read -r line; do
            art+=("$line")
        done < "$art_file"
    fi

    # --- layout: info block vertically centered against portrait ---
    local art_n=${#art[@]}
    local info_n=${#info[@]}
    local top_pad=$(( (art_n - info_n) / 2 ))
    (( top_pad < 0 )) && top_pad=0
    local total_rows=$(( art_n > (top_pad + info_n) ? art_n : (top_pad + info_n) ))

    # portrait color applied at printf time so ${#al} padding math stays correct
    local i al al_vw al_pad ri rl
    for ((i=1; i<=total_rows; i++)); do
        al="${art[$i]:-}"
        al_vw=${#al}
        al_pad=$(( PORTRAIT_W - al_vw ))
        (( al_pad < 0 )) && al_pad=0

        ri=$(( i - top_pad ))
        rl=""
        (( ri >= 1 && ri <= info_n )) && rl="${info[$ri]}"

        if [[ -n "$PORTRAIT_C" && -n "$al" ]]; then
            printf "${PORTRAIT_C}%s${RESET}%*s%*s%s\n" \
                "$al" "$al_pad" '' "$GAP" '' "$rl"
        else
            printf "%s%*s%*s%s\n" "$al" "$al_pad" '' "$GAP" '' "$rl"
        fi
    done
    printf '\n'
}

_welcome_main
unfunction _welcome_main 2>/dev/null
