# terminal-welcome

A minimal Mac terminal welcome dashboard. Braille portrait on the left, your name in figlet on the right, live weather, uptime, and a daily wish. No boxes. No emojis. No borders.

<br>

<!-- Replace with your own screenshot -->
![terminal-welcome preview](https://raw.githubusercontent.com/yourusername/terminal-welcome/main/docs/preview.png)

<br>

## Install

```bash
git clone https://github.com/yourusername/terminal-welcome.git && cd terminal-welcome && bash install.sh
```

The installer will guide you through everything. Takes about 2 minutes.

**Requirements:** macOS, [Homebrew](https://brew.sh) (installed automatically if missing)

<br>

## What you get

```
⣿⣿⣿⣿⡿⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿    /|_/\  ___  _   _
⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇    / / / / -_) | | |
⠀⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿    \_/\_/\___| |___|
⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁
⠀⠀⠀⠻⣿⣿⣿⣿⣿⣿⠟⠀       Thursday, May 01 2026
⠀⠀⠀⠀⠈⠙⠻⠿⠛⠁          09:41
                          Partly cloudy, +14°C
                          uptime  3 days
                          zsh

                          Make something beautiful today.
```

<br>

## Features

- **Braille ASCII portrait** — drag & drop your photo during install, auto-converted
- **figlet name heading** — `slant` font, in your chosen accent color
- **Live weather** — from [wttr.in](https://wttr.in), cached per hour, no API key needed
- **Two independent color themes** — pick portrait color and accent color separately
- **Zero dependencies at runtime** — just curl, figlet, and your terminal
- **Non-destructive** — installs to `~/.config/terminal-welcome/`, won't touch existing configs

<br>

## Customization

After install, open your copy:

```bash
nano ~/.config/terminal-welcome/welcome.sh
```

The config block at the top is all you need to touch:

```bash
# ── YOUR CONFIG ──────────────────
YOUR_NAME="Alex"             # your name for figlet heading
YOUR_CITY="Tokyo"            # for weather e.g. "New York"
TEMP_UNIT="metric"           # metric or imperial
PORTRAIT_COLOR="38;5;218"   # ANSI code — 97=white, 38;5;218=pink, 96=cyan, 92=green
ACCENT_COLOR="96"            # ANSI code for your figlet name
WISHES=(
  "Make something beautiful today."
  "Ship it."
  # add your own here
)
# ─────────────────────────────────
```

### Swap your portrait

Convert any photo to braille art and replace the file:

```bash
ascii-image-converter your-photo.jpg --braille -W 50 \
  | sed $'s/\033\\[[0-9;]*m//g' \
  > ~/.config/terminal-welcome/ascii.txt
```

### Common ANSI color codes

| Color  | Code       |
|--------|------------|
| White  | `97`       |
| Pink   | `38;5;218` |
| Cyan   | `96`       |
| Green  | `92`       |
| Yellow | `33`       |
| Orange | `38;5;208` |
| Purple | `38;5;183` |

<br>

## Uninstall

```bash
rm -rf ~/.config/terminal-welcome
```

Then remove the `source ~/.config/terminal-welcome/welcome.sh` line from your `~/.zshrc`.

<br>

## Contributing

Bug reports and PRs are welcome. Please use the issue templates provided.

<br>

## License

MIT © 2026
