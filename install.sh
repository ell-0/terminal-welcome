#!/usr/bin/env bash
set -euo pipefail

# ── colors ────────────────────────────────────────────────────────────────────
RED=$'\033[31m'
GREEN=$'\033[32m'
CYAN=$'\033[96m'
PINK=$'\033[38;5;218m'
WHITE=$'\033[97m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

INSTALL_DIR="$HOME/.config/terminal-welcome"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ───────────────────────────────────────────────────────────────────
banner() {
    printf '\n'
    printf '%s\n' "${PINK}${BOLD}  terminal-welcome${RESET}"
    printf '%s\n' "${CYAN}  ──────────────────────────────────────────────────${RESET}"
    printf '%s\n' "  A minimal Mac terminal welcome dashboard."
    printf '%s\n' "  Takes about 2 minutes to set up."
    printf '\n'
}

step() { printf '%s %s\n'  "${CYAN}→${RESET}"     "$1"; }
ok()   { printf '%s %s\n'  "${GREEN}✓${RESET}"    "$1"; }
warn() { printf '%s %s\n'  "${RED}!${RESET}"      "$1"; }
ask()  { printf '%s %s '   "${PINK}?${RESET}"     "$1"; }

# ── color picker ──────────────────────────────────────────────────────────────
# All display output goes to stderr; only the bare ANSI code reaches stdout.
# This keeps $(color_pick ...) free of newlines so substitution stays clean.
color_pick() {
    local label="$1"
    printf '\n  %s\n' "$label" >&2
    printf '    %s\n' "1) White   2) Pink   3) Cyan   4) Green   5) Custom ANSI" >&2
    printf '%s %s ' "${PINK}?${RESET}" "  Choose [1-5]:" >&2
    local choice
    read -r choice
    case "$choice" in
        1) printf '%s' "97"        ;;
        2) printf '%s' "38;5;218"  ;;
        3) printf '%s' "96"        ;;
        4) printf '%s' "92"        ;;
        5)
            printf '%s %s ' "${PINK}?${RESET}" \
                "  Enter ANSI code (e.g. 33 = yellow, 38;5;208 = orange):" >&2
            local custom
            read -r custom
            printf '%s' "${custom:-97}"
            ;;
        *) printf '%s' "97"        ;;
    esac
}

# ── dependency checks ─────────────────────────────────────────────────────────
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

# ── gather user config ────────────────────────────────────────────────────────
# Sets: USER_NAME, USER_CITY, USER_TEMP_UNIT, USER_PORTRAIT_COLOR, USER_ACCENT_COLOR
gather_info() {
    printf '%s\n\n' "  ${BOLD}Let's build your dashboard.${RESET}"

    ask "What's your name?"
    read -r USER_NAME
    USER_NAME="${USER_NAME:-You}"

    printf '\n'
    ask "What city are you in? (used for weather, e.g. London, Tokyo, New York)"
    read -r USER_CITY
    USER_CITY="${USER_CITY:-London}"

    printf '\n  Temperature unit:\n'
    printf '    1) Celsius   2) Fahrenheit\n'
    ask "  Choose [1-2]:"
    local unit_choice
    read -r unit_choice
    [[ "$unit_choice" == "2" ]] && USER_TEMP_UNIT="imperial" || USER_TEMP_UNIT="metric"

    USER_PORTRAIT_COLOR=$(color_pick "Portrait color:")
    USER_ACCENT_COLOR=$(color_pick "Accent color  (for your name heading):")
    printf '\n'
}

# ── photo → ASCII art ─────────────────────────────────────────────────────────
process_photo() {
    printf '  %s\n' "Drag & drop a photo here, or press ${WHITE}Enter${RESET} to use the built-in placeholder."
    ask "  Photo path (or Enter to skip):"
    local photo_path
    read -r photo_path

    # strip leading space and surrounding quotes added by macOS drag-drop in Finder
    photo_path="${photo_path# }"
    photo_path="${photo_path#\'}" ; photo_path="${photo_path%\'}"
    photo_path="${photo_path#\"}" ; photo_path="${photo_path%\"}"
    photo_path="${photo_path# }"
    # unescape backslash-escaped spaces (e.g. /My\ Photos/x.jpg → /My Photos/x.jpg)
    photo_path="${photo_path//\\ / }"

    mkdir -p "$INSTALL_DIR"

    if [[ -n "$photo_path" && -f "$photo_path" ]]; then
        step "Converting photo to braille ASCII art..."
        ascii-image-converter "$photo_path" --braille -W 50 2>/dev/null \
            | sed $'s/\033\\[[0-9;]*m//g' \
            > "$INSTALL_DIR/ascii.txt"
        ok "Photo converted"
    else
        step "Using built-in placeholder portrait..."
        cp "$SCRIPT_DIR/ascii/placeholder.txt" "$INSTALL_DIR/ascii.txt"
        ok "Placeholder copied"
    fi
    printf '\n'
}

# ── install script ────────────────────────────────────────────────────────────
install_script() {
    step "Installing dashboard to $INSTALL_DIR..."

    python3 -c "
import sys
t = open(sys.argv[1]).read()
keys   = sys.argv[2::2]
values = sys.argv[3::2]
for k, v in zip(keys, values):
    t = t.replace(k, v)
sys.stdout.write(t)
" "$SCRIPT_DIR/welcome.sh" \
      '__YOUR_NAME__'      "$USER_NAME"            \
      '__YOUR_CITY__'      "$USER_CITY"            \
      '__TEMP_UNIT__'      "$USER_TEMP_UNIT"       \
      '__PORTRAIT_COLOR__' "$USER_PORTRAIT_COLOR"  \
      '__ACCENT_COLOR__'   "$USER_ACCENT_COLOR"    \
      > "$INSTALL_DIR/welcome.sh"

    chmod +x "$INSTALL_DIR/welcome.sh"
    ok "welcome.sh installed"
}

# ── add source line to shell rc ───────────────────────────────────────────────
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
        ok "Added source line to $shell_rc"
    fi
}

# ── success ───────────────────────────────────────────────────────────────────
show_success() {
    printf '\n%s\n' "${CYAN}──────────────────────────────────────────────────${RESET}"
    printf '%s\n\n' "  ${BOLD}Preview:${RESET}"
    zsh "$INSTALL_DIR/welcome.sh" 2>/dev/null || true
    printf '\n'
    printf '%s\n' "  ${GREEN}${BOLD}All done!${RESET}"
    printf '%s\n' "  Open a new terminal tab to see your dashboard."
    printf '%s\n' "  To tweak it later:"
    printf '%s\n' "    ${WHITE}nano ~/.config/terminal-welcome/welcome.sh${RESET}"
    printf '\n'
}

# ── main ──────────────────────────────────────────────────────────────────────
main() {
    banner
    check_deps
    gather_info
    process_photo
    install_script
    add_to_shell
    show_success
}

main
