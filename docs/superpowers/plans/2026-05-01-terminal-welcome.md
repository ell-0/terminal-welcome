# terminal-welcome Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and publish a complete open-source Mac terminal welcome dashboard as a proper GitHub repository.

**Architecture:** `welcome.sh` is a zsh script with a `# YOUR CONFIG` block at the top containing `__PLACEHOLDER__` tokens; `install.sh` collects user answers via interactive prompts, `sed`-substitutes those tokens, and drops the filled-in script into `~/.config/terminal-welcome/`. The portrait is stored as braille plain text in `ascii.txt` alongside the script.

**Tech Stack:** zsh, bash (installer), figlet, wttr.in (weather), ascii-image-converter (brew), sed, curl

---

### Task 1: Create repo skeleton

**Files:**
- Create: `~/GitHub/terminal-welcome/ascii/` (dir)
- Create: `~/GitHub/terminal-welcome/.github/ISSUE_TEMPLATE/` (dir)

- [ ] **Step 1: Create directories and verify**

```bash
mkdir -p ~/GitHub/terminal-welcome/ascii \
         ~/GitHub/terminal-welcome/.github/ISSUE_TEMPLATE
ls ~/GitHub/terminal-welcome/
```
Expected: `ascii/  .github/`

- [ ] **Step 2: Init git repo**

```bash
cd ~/GitHub/terminal-welcome && git init
```
Expected: `Initialized empty Git repository`

---

### Task 2: Write `welcome.sh` template

**Files:**
- Create: `~/GitHub/terminal-welcome/welcome.sh`

The script must be valid zsh. Config block uses `__PLACEHOLDER__` tokens replaced by the installer via `sed`. Portrait color is applied at `printf` time (not stored in the art array) so `${#line}` padding math stays correct. Weather is cached per-city per-hour in `/tmp`.

- [ ] **Step 1: Write the file**

```bash
cat > ~/GitHub/terminal-welcome/welcome.sh << 'ENDOFSCRIPT'
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
            printf "${PORTRAIT_C}%s${RESET}%*s%*s%s\n" "$al" "$al_pad" '' "$GAP" '' "$rl"
        else
            printf "%s%*s%*s%s\n" "$al" "$al_pad" '' "$GAP" '' "$rl"
        fi
    done
    printf '\n'
}

_welcome_main
unfunction _welcome_main 2>/dev/null
ENDOFSCRIPT
```

- [ ] **Step 2: Validate bash/zsh syntax**

```bash
zsh -n ~/GitHub/terminal-welcome/welcome.sh && echo "OK"
```
Expected: `OK`

---

### Task 3: Write `install.sh`

**Files:**
- Create: `~/GitHub/terminal-welcome/install.sh`

Friendly, colored, guided installer. Checks dependencies, collects config, converts or copies ASCII art, sed-fills the template, adds source line to shell rc if not present, shows live preview.

- [ ] **Step 1: Write the file**

```bash
cat > ~/GitHub/terminal-welcome/install.sh << 'ENDOFSCRIPT'
#!/usr/bin/env bash
set -euo pipefail

# ── colors ──────────────────────────────────────────────────────────
RED=$'\033[31m'
GREEN=$'\033[32m'
CYAN=$'\033[96m'
PINK=$'\033[38;5;218m'
WHITE=$'\033[97m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

INSTALL_DIR="$HOME/.config/terminal-welcome"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ──────────────────────────────────────────────────────────
banner() {
    printf '\n'
    printf '%s\n' "${PINK}${BOLD}  terminal-welcome${RESET}"
    printf '%s\n' "${CYAN}  ────────────────────────────────────────${RESET}"
    printf '%s\n' "  A minimal Mac terminal welcome dashboard."
    printf '\n'
}

step() { printf '%s %s\n' "${CYAN}→${RESET}" "$1"; }
ok()   { printf '%s %s\n' "${GREEN}✓${RESET}" "$1"; }
warn() { printf '%s %s\n' "${RED}!${RESET}" "$1"; }
ask()  { printf '%s %s ' "${PINK}?${RESET}" "$1"; }

color_pick() {
    local label="$1"
    printf '\n'
    printf '  %s\n' "$label"
    printf '  %s\n' "  1) White   2) Pink   3) Cyan   4) Green   5) Custom ANSI"
    ask "Choose [1-5]:"
    read -r choice
    case "$choice" in
        1) printf '%s' "97" ;;
        2) printf '%s' "38;5;218" ;;
        3) printf '%s' "96" ;;
        4) printf '%s' "92" ;;
        5)
            ask "Enter ANSI code (e.g. 33 = yellow, 38;5;208 = orange):"
            read -r custom
            printf '%s' "${custom:-97}"
            ;;
        *) printf '%s' "97" ;;
    esac
}

# ── dependency checks ────────────────────────────────────────────────
check_deps() {
    step "Checking dependencies..."
    printf '\n'

    if ! command -v brew &>/dev/null; then
        warn "Homebrew not found — installing it now (this may take a minute)..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    ok "Homebrew"

    if ! command -v figlet &>/dev/null; then
        step "Installing figlet..."
        brew install figlet --quiet
    fi
    ok "figlet"

    if ! command -v ascii-image-converter &>/dev/null; then
        step "Installing ascii-image-converter..."
        brew install TheZoraiz/ascii-image-converter/ascii-image-converter --quiet
    fi
    ok "ascii-image-converter"
    printf '\n'
}

# ── gather user config ───────────────────────────────────────────────
gather_info() {
    printf '%s\n\n' "${BOLD}  Let's build your dashboard.${RESET}"

    ask "What's your name?"
    read -r USER_NAME
    USER_NAME="${USER_NAME:-You}"

    ask "What city are you in? (for weather, e.g. London)"
    read -r USER_CITY
    USER_CITY="${USER_CITY:-London}"

    printf '\n  Temperature unit:\n'
    printf '  1) Celsius   2) Fahrenheit\n'
    ask "Choose [1-2]:"
    read -r unit_choice
    [[ "$unit_choice" == "2" ]] && USER_TEMP_UNIT="imperial" || USER_TEMP_UNIT="metric"

    USER_PORTRAIT_COLOR=$(color_pick "Portrait color:")
    USER_ACCENT_COLOR=$(color_pick "Accent color (for your name):")
    printf '\n'
}

# ── photo → ASCII art ────────────────────────────────────────────────
process_photo() {
    printf '  %s\n' "Drag & drop a photo here, or press ${WHITE}Enter${RESET} to use the placeholder."
    ask "Photo path (or Enter to skip):"
    read -r photo_path

    # strip leading space and surrounding quotes added by macOS drag-drop
    photo_path="${photo_path# }"
    photo_path="${photo_path#\'}" ; photo_path="${photo_path%\'}"
    photo_path="${photo_path#\"}" ; photo_path="${photo_path%\"}"

    if [[ -n "$photo_path" && -f "$photo_path" ]]; then
        step "Converting photo to braille ASCII art..."
        ascii-image-converter "$photo_path" --braille -W 50 2>/dev/null \
            | sed $'s/\033\\[[0-9;]*m//g' \
            > "$INSTALL_DIR/ascii.txt"
        ok "Photo converted and saved"
    else
        step "Using built-in placeholder portrait..."
        cp "$SCRIPT_DIR/ascii/placeholder.txt" "$INSTALL_DIR/ascii.txt"
        ok "Placeholder copied"
    fi
    printf '\n'
}

# ── install ──────────────────────────────────────────────────────────
install_script() {
    step "Installing to $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"

    sed \
        -e "s|__YOUR_NAME__|${USER_NAME}|g" \
        -e "s|__YOUR_CITY__|${USER_CITY}|g" \
        -e "s|__TEMP_UNIT__|${USER_TEMP_UNIT}|g" \
        -e "s|__PORTRAIT_COLOR__|${USER_PORTRAIT_COLOR}|g" \
        -e "s|__ACCENT_COLOR__|${USER_ACCENT_COLOR}|g" \
        "$SCRIPT_DIR/welcome.sh" > "$INSTALL_DIR/welcome.sh"

    chmod +x "$INSTALL_DIR/welcome.sh"
    ok "welcome.sh installed"
}

# ── shell rc ─────────────────────────────────────────────────────────
add_to_shell() {
    local shell_rc
    if [[ -f "$HOME/.zshrc" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -f "$HOME/.bash_profile" ]]; then
        shell_rc="$HOME/.bash_profile"
    else
        shell_rc="$HOME/.zshrc"
        touch "$shell_rc"
    fi

    local source_line="source ~/.config/terminal-welcome/welcome.sh"
    if grep -qF "$source_line" "$shell_rc" 2>/dev/null; then
        ok "Already in $shell_rc — no changes needed"
    else
        printf '\n# terminal-welcome\n%s\n' "$source_line" >> "$shell_rc"
        ok "Added to $shell_rc"
    fi
}

# ── preview ──────────────────────────────────────────────────────────
show_preview() {
    printf '\n%s\n' "${CYAN}────────────────────────────────────────${RESET}"
    printf '%s\n\n' "${BOLD}  Preview:${RESET}"
    zsh "$INSTALL_DIR/welcome.sh" 2>/dev/null || true
    printf '\n%s\n' "${GREEN}${BOLD}  All done!${RESET} Open a new terminal tab to see your dashboard."
    printf '  To edit your config later: %s\n\n' "${WHITE}nano ~/.config/terminal-welcome/welcome.sh${RESET}"
}

# ── main ─────────────────────────────────────────────────────────────
main() {
    banner
    check_deps
    gather_info
    process_photo
    install_script
    add_to_shell
    show_preview
}

main
ENDOFSCRIPT
```

- [ ] **Step 2: Make executable and validate syntax**

```bash
chmod +x ~/GitHub/terminal-welcome/install.sh
bash -n ~/GitHub/terminal-welcome/install.sh && echo "OK"
```
Expected: `OK`

---

### Task 4: Create `ascii/placeholder.txt`

**Files:**
- Create: `~/GitHub/terminal-welcome/ascii/placeholder.txt`

Generic braille portrait, ~22 lines × ~50 chars, works out of the box without a photo.

- [ ] **Step 1: Write placeholder braille art**

Write a clean generic silhouette directly to the file (see content in implementation section).

- [ ] **Step 2: Verify line count**

```bash
wc -l ~/GitHub/terminal-welcome/ascii/placeholder.txt
```
Expected: between 18 and 28 lines.

---

### Task 5: Write `README.md`

**Files:**
- Create: `~/GitHub/terminal-welcome/README.md`

Beautiful README: screenshot placeholder, one-liner install, features list, customization guide.

---

### Task 6: Write `LICENSE`

**Files:**
- Create: `~/GitHub/terminal-welcome/LICENSE`

MIT license, copyright 2026.

---

### Task 7: Write `.github/ISSUE_TEMPLATE/bug_report.md`

**Files:**
- Create: `~/GitHub/terminal-welcome/.github/ISSUE_TEMPLATE/bug_report.md`

Standard GitHub bug report template.

---

### Task 8: Initial git commit

- [ ] **Step 1: Stage and commit all files**

```bash
cd ~/GitHub/terminal-welcome
git add .
git commit -m "feat: initial release — terminal-welcome dashboard"
```
Expected: commit hash printed.
